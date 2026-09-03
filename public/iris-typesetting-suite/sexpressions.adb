--  sexpressions.adb --- R7RS Scheme S-Expression I/O Implementation
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces;
with ada.exceptions;
with ada.characters.conversions;
with ada.strings;
with ada.strings.fixed;
with ada.strings.wide_wide_hash;
with ada.wide_wide_text_io;
with ada.containers.indefinite_vectors;
with ada.containers.indefinite_hashed_sets;
with ada.containers.indefinite_hashed_maps;
with ada.containers.hashed_maps;
with sequential_identifiers;

package body sexpressions is

   use interfaces;
   use ada.containers;
   use ada.wide_wide_text_io;
   use bignum_integers;
   use exact_reals;
   use exact_reals_conversions;
   use sexpr_characters_handling;
   use sexpr_strings;
   use sequential_identifiers;

   package conv renames ada.characters.conversions;

   package sexpr_fixstr_to_integer_maps is new
     indefinite_hashed_maps
       (key_type        => sexpr_fixstr,
        element_type    => integer,
        hash            => hash_sexpr_fixstr,
        equivalent_keys => "=");
   subtype sexpr_fixstr_to_integer_map is
     sexpr_fixstr_to_integer_maps.map;

   package sexpr_fixstr_to_sexpr_maps is new
     indefinite_hashed_maps
       (key_type        => sexpr_fixstr,
        element_type    => sexpr,
        hash            => hash_sexpr_fixstr,
        equivalent_keys => "=");
   subtype sexpr_fixstr_to_sexpr_map is sexpr_fixstr_to_sexpr_maps.map;

   package sexpr_sets is new
     indefinite_hashed_sets
       (element_type        => sexpr,
        hash                => hash_sexpr,
        equivalent_elements => sexpr_equivalents);
   subtype sexpr_set is sexpr_sets.set;

   package sexpr_to_natural_maps is new
     indefinite_hashed_maps
       (key_type        => sexpr,
        element_type    => natural,
        hash            => hash_sexpr,
        equivalent_keys => sexpr_equivalents);
   subtype sexpr_to_natural_map is sexpr_to_natural_maps.map;

   package sexpr_identifier_to_natural_maps is new
     indefinite_hashed_maps
       (key_type        => sexpr_identifier,
        element_type    => natural,
        hash            => hash_sexpr_identifier,
        equivalent_keys => sexpr_identifier_equivalents);
   subtype sexpr_identifier_to_natural_map is
     sexpr_identifier_to_natural_maps.map;

   ---------------------------------------------------------------------

   sexpr_nul       : constant sexpr_character :=
     sexpr_character'val (0);
   sexpr_alarm     : constant sexpr_character :=
     sexpr_character'val (7);
   sexpr_backspace : constant sexpr_character :=
     sexpr_character'val (8);
   sexpr_tab       : constant sexpr_character :=
     sexpr_character'val (9);
   sexpr_newline   : constant sexpr_character :=
     sexpr_character'val (10);
   sexpr_vtab      : constant sexpr_character :=
     sexpr_character'val (11)
   with unreferenced;
   sexpr_page      : constant sexpr_character :=
     sexpr_character'val (12);
   sexpr_return    : constant sexpr_character :=
     sexpr_character'val (13);

   plus_inf  : constant sexpr_string :=
     to_sexpr_string (sexpr_fixstr'("+inf.0"));
   minus_inf : constant sexpr_string :=
     to_sexpr_string (sexpr_fixstr'("-inf.0"));
   plus_nan  : constant sexpr_string :=
     to_sexpr_string (sexpr_fixstr'("+nan.0"));
   minus_nan : constant sexpr_string :=
     to_sexpr_string (sexpr_fixstr'("-nan.0"));

   ---------------------------------------------------------------------

   type node_record (kind : sexpr_kind) is tagged record
      case kind is
         when sexpr_kind_null =>
            null;

         when sexpr_kind_boolean =>
            boolean_val : boolean;

         when sexpr_kind_integer =>
            integer_val : bignum_integer;

         when sexpr_kind_inexact =>
            inexact_val : inexact_real;

         when sexpr_kind_rational =>
            rational_val : exact_real;

         when sexpr_kind_character =>
            character_val : sexpr_character;

         when sexpr_kind_string =>
            string_val : sexpr_string;

         when sexpr_kind_symbol =>
            symbol_val : sexpr_string;

         when sexpr_kind_pair =>
            pair_val : sexpr_identifier_vector;

         when sexpr_kind_vector =>
            vector_val : sexpr_identifier_vector;

         when sexpr_kind_bytevector =>
            bytevector_val : unsigned_8_vector;
      end case;
   end record;

   ---------------------------------------------------------------------

   type node_registry_record is new node_record with record
      identifier : sexpr_identifier;
   end record;

   package sexpr_identifier_to_node_registry_record_maps is new
     indefinite_hashed_maps
       (key_type        => sexpr_identifier,
        element_type    => node_registry_record,
        hash            => hash_sexpr_identifier,
        equivalent_keys => sexpr_identifier_equivalents);

   package sexpr_identifier_to_positive_maps is new
     hashed_maps
       (key_type        => sexpr_identifier,
        element_type    => positive,
        hash            => hash_sexpr_identifier,
        equivalent_keys => sexpr_identifier_equivalents);

   protected type node_registry_type is
      procedure insert
        (key : in sexpr_identifier; value : in node_registry_record);
      function contains (key : in sexpr_identifier) return boolean;
      function reference_count
        (key : in sexpr_identifier) return natural;
      procedure increment_reference_count (key : in sexpr_identifier);
      procedure decrement_reference_count (key : in sexpr_identifier);
      function element
        (key : in sexpr_identifier) return node_registry_record;
   private
      nodes     : sexpr_identifier_to_node_registry_record_maps.map;
      refcounts : sexpr_identifier_to_positive_maps.map;
   end node_registry_type;

   protected body node_registry_type is

      procedure insert
        (key : in sexpr_identifier; value : in node_registry_record) is
      begin
         nodes.insert (key, value);
         refcounts.insert (key, 1);
      end insert;

      function contains (key : in sexpr_identifier) return boolean is
      begin
         return refcounts.contains (key);
      end contains;

      function reference_count
        (key : in sexpr_identifier) return natural is
      begin
         return
           (if refcounts.contains (key)
            then refcounts.element (key)
            else 0);
      end reference_count;

      procedure increment_reference_count (key : in sexpr_identifier) is
      begin
         refcounts.include (key, refcounts.element (key) + 1);
      end increment_reference_count;

      procedure decrement_reference_count (key : in sexpr_identifier) is
         procedure decrement_other_node (key2 : in sexpr_identifier) is
         begin
            if key2 /= key then
               decrement_reference_count (key2);
            end if;
         end decrement_other_node;

         refcount : constant positive := refcounts.element (key);
      begin
         if refcount /= 1 then
            refcounts.include (key, refcount - 1);
         else
            declare
               node : node_registry_record := nodes.element (key);
            begin
               case node.kind is
                  when sexpr_kind_pair   =>
                     for each of node.pair_val loop
                        decrement_other_node (each);
                     end loop;

                  when sexpr_kind_vector =>
                     for each of node.vector_val loop
                        decrement_other_node (each);
                     end loop;

                  when others            =>
                     null;
               end case;
               nodes.delete (key);
               refcounts.delete (key);
            end;
         end if;
      end decrement_reference_count;

      function element
        (key : in sexpr_identifier) return node_registry_record is
      begin
         return nodes.element (key);
      end element;

   end node_registry_type;

   ---------------------------------------------------------------------

   node_registry : node_registry_type;

   function make_sexpr_identifier
     (node : in node_record) return sexpr_identifier is
   begin
      return identifier : sexpr_identifier := next_sequential_identifier
      do
         node_registry.insert
           (identifier, (node with identifier => identifier));
      end return;
   end make_sexpr_identifier;

   function make_sexpr (node : in node_record) return sexpr is
   begin
      return
        (controlled with identifier => make_sexpr_identifier (node));
   end make_sexpr;

   function get_node (key : in sexpr_identifier) return node_record is
   begin
      return node_record (node_registry.element (key));
   end get_node;

   function get_node (key : in sexpr) return node_record is
   begin
      return node_record (node_registry.element (key.identifier));
   end get_node;

   overriding
   procedure adjust (object : in out sexpr) is
   begin
      node_registry.increment_reference_count (object.identifier);
   end adjust;

   overriding
   procedure finalize (object : in out sexpr) is
   begin
      node_registry.decrement_reference_count (object.identifier);
   end finalize;

   ---------------------------------------------------------------------

   function hash_sexpr (key : in sexpr) return hash_type is
   begin
      return hash_sexpr_identifier (key.identifier);
   end hash_sexpr;

   function sexpr_equivalents (left, right : in sexpr) return boolean is
   begin
      return
        sexpr_identifier_equivalents
          (left.identifier, right.identifier);
   end sexpr_equivalents;

   ---------------------------------------------------------------------

   type parse_context is record
      src : sexpr_string;
      pos : positive := 1;
      len : natural := 0;
      -- fold_case : boolean := false;
   end record;

   function is_eof (ctx : in parse_context) return boolean is
      res : boolean := (ctx.pos > ctx.len);
   begin
      return res;
   end is_eof;

   function peek_char
     (ctx : in parse_context; index : in natural := 0)
      return sexpr_character
   is
      res : sexpr_character := sexpr_nul;
   begin
      if ctx.pos + index <= ctx.len then
         res := element (ctx.src, ctx.pos + index);
      end if;
      return res;
   end peek_char;

   function peek_next_char
     (ctx : in parse_context) return sexpr_character is
   begin
      return peek_char (ctx => ctx, index => 1);
   end peek_next_char;

   --
   -- adv_char:
   --
   -- Advance by “amount”. Negative amounts are for backtracking.
   --
   procedure adv_char
     (ctx : in out parse_context; amount : integer := 1) is
   begin
      if amount < 0 then
         if 1 <= ctx.pos + amount then
            ctx.pos := ctx.pos + amount;
         end if;
      else
         if ctx.pos + amount <= ctx.len + 1 then
            ctx.pos := ctx.pos + amount;
         end if;
      end if;
   end adv_char;

   ---------------------------------------------------------------------

   function is_graphic_delimiter
     (item : in sexpr_character) return boolean is
   begin
      return item in '(' | ')' | '"' | ';' | '|';
   end is_graphic_delimiter;

   function is_delimiter (item : in sexpr_character) return boolean is
   begin
      return
        is_space (item)
        or is_control (item)
        or is_graphic_delimiter (item);
   end is_delimiter;

   function is_special_initial (item : sexpr_character) return boolean
   is
   begin
      return
        item
        in '!'
         | '$'
         | '%'
         | '&'
         | '*'
         | '/'
         | ':'
         | '<'
         | '='
         | '>'
         | '?'
         | '@'
         | '^'
         | '_'
         | '~';
   end is_special_initial;

   function is_explicit_sign (item : in sexpr_character) return boolean
   is
   begin
      return item in '-' | '+';
   end is_explicit_sign;

   function is_special_subsequent
     (item : in sexpr_character) return boolean is
   begin
      return is_explicit_sign (item) or item in '.' | '@';
   end is_special_subsequent;

   function is_identifier_initial
     (item : in sexpr_character) return boolean is
   begin
      return is_letter (item) or is_special_initial (item);
   end is_identifier_initial;

   function is_identifier_subsequent
     (item : in sexpr_character) return boolean is
   begin
      return
        is_identifier_initial (item)
        or is_digit (item)
        or is_special_subsequent (item);
   end is_identifier_subsequent;

   function collect_while
     (ctx       : in out parse_context;
      predicate :
        access function (item : in sexpr_character) return boolean)
      return sexpr_string
   is
      s : sexpr_string := null_sexpr_string;
   begin
      while not is_eof (ctx) and then predicate (peek_char (ctx)) loop
         s := @ & peek_char (ctx);
         adv_char (ctx);
      end loop;
      return s;
   end collect_while;

   --
   -- collect_identifier:
   --
   -- Obtain a Scheme identifier from the context.
   --
   function collect_identifier
     (ctx : in out parse_context) return sexpr_string
   is
      s : sexpr_string;
   begin
      if not is_eof (ctx) and is_identifier_initial (peek_char (ctx))
      then
         -- Any identifier initial is also a legal subsequent, and
         -- thus the following is correct code.
         s :=
           collect_while
             (ctx, predicate => is_identifier_subsequent'access);
      else
         s := null_sexpr_string;
      end if;
      return s;
   end collect_identifier;

   function collect_until_delimiter
     (ctx : in out parse_context) return sexpr_string
   is
      function pred (item : in sexpr_character) return boolean is
      begin
         return not is_delimiter (item);
      end pred;
   begin
      return collect_while (ctx, predicate => pred'access);
   end collect_until_delimiter;

   type numerical_exactness is
     (numerical_exactness_unspecified,
      numerically_exact,
      numerically_inexact);

   --
   -- is_radix:
   --
   -- Is “item” a valid radix for a Scheme numeral?
   --
   function is_radix (item : in integer) return boolean
   with post => is_radix'result = (item in 2 | 8 | 10 | 16)
   is
   begin
      return (item in 2 | 8 | 10 | 16);
   end is_radix;

   function trim_left (source : in string) return string is
   begin
      return
        ada.strings.fixed.trim
          (source => source, side => ada.strings.left);
   end trim_left;

   character_name_lookup : sexpr_fixstr_to_integer_map;

   procedure initialize_character_name_lookup is
   begin
      --
      -- FIXME: MAKE THIS EXTENSIBLE BY CONFIGURATION.
      --

      -- Start of character names required by R⁷RS-small.
      character_name_lookup.include ("null", 0);
      character_name_lookup.include ("alarm", 7);
      character_name_lookup.include ("backspace", 8);
      character_name_lookup.include ("tab", 9);
      character_name_lookup.include ("newline", 10);
      character_name_lookup.include ("return", 13);
      character_name_lookup.include ("escape", 27);
      character_name_lookup.include ("space", 32);
      character_name_lookup.include ("delete", 127);
      -- End of character names required by R⁷RS-small.

      --
      -- Names shall not be confusable with hexadecimal codes that
      -- start with x or X.
      --
      character_name_lookup.include ("nul", 0);
      character_name_lookup.include ("bell", 7);
      character_name_lookup.include ("bel", 7);
      character_name_lookup.include ("bs", 8);
      character_name_lookup.include ("ht", 9);
      character_name_lookup.include ("nl", 10);
      character_name_lookup.include ("lf", 10);
      character_name_lookup.include ("vtab", 11);
      character_name_lookup.include ("vt", 11);
      character_name_lookup.include ("page", 12);
      character_name_lookup.include ("formfeed", 12);
      character_name_lookup.include ("ff", 12);
      character_name_lookup.include ("cr", 13);
      character_name_lookup.include ("esc", 27);
      character_name_lookup.include ("del", 127);
      character_name_lookup.include ("nobreakspace", 16#A0#);
      character_name_lookup.include ("nbsp", 16#A0#);
      character_name_lookup.include ("section", 16#A7#);
      character_name_lookup.include ("sect", 16#A7#);
      character_name_lookup.include ("copyright", 16#A9#);
      character_name_lookup.include ("copy", 16#A9#);
      character_name_lookup.include ("registered", 16#AE#);
      character_name_lookup.include ("regmark", 16#AE#);
      character_name_lookup.include ("reg", 16#AE#);
      character_name_lookup.include ("pilcrow", 16#B6#);
      character_name_lookup.include ("paragraph", 16#B6#);
      character_name_lookup.include ("para", 16#B6#);
      character_name_lookup.include ("thinspace", 16#2009#);
      character_name_lookup.include ("thinsp", 16#2009#);
      character_name_lookup.include ("narrownobreakspace", 16#202F#);
      character_name_lookup.include ("nnbsp", 16#202F#);
      character_name_lookup.include ("wordjoiner", 16#2060#);
      character_name_lookup.include ("wj", 16#2060#);
      character_name_lookup.include ("trademark", 16#2122#);
      character_name_lookup.include ("trade", 16#2122#);
   end initialize_character_name_lookup;

   slash : constant sexpr_fixstr := sexpr_fixstr'("/");

   function contains_slash (source : in sexpr_string) return boolean is
   begin
      return (0 < index (source, slash));
   end contains_slash;

   function is_ascii (item : in sexpr_character) return boolean is
   begin
      return (sexpr_character'pos (item) <= 127);
   end is_ascii;

   function is_binary_digit (item : in sexpr_character) return boolean
   is
   begin
      return
        (item = sexpr_character'('0') or item = sexpr_character'('1'));
   end is_binary_digit;

   function is_octal_digit (item : in sexpr_character) return boolean is
   begin
      return (item in sexpr_character'('0') .. sexpr_character'('7'));
   end is_octal_digit;

   function is_ascii_digit (item : in sexpr_character) return boolean is
   begin
      return (item in sexpr_character'('0') .. sexpr_character'('9'));
   end is_ascii_digit;

   function is_member
     (item : in sexpr_character; in_array : in sexpr_character_array)
      return boolean is
   begin
      return (for some element of in_array => item = element);
   end is_member;

   function is_member
     (item : in sexpr_string; in_array : in sexpr_string_array)
      return boolean is
   begin
      return (for some element of in_array => item = element);
   end is_member;

   function to_sexpr_fixstr (source : in string) return sexpr_fixstr is
   begin
      return conv.to_wide_wide_string (source);
   end to_sexpr_fixstr;

   function to_sexpr_string (source : in string) return sexpr_string is
   begin
      return to_sexpr_string (conv.to_wide_wide_string (source));
   end to_sexpr_string;

   function to_string (source : in sexpr_fixstr) return string is
   begin
      return conv.to_string (source);
   end to_string;

   function to_string (source : in sexpr_string) return string is
   begin
      return conv.to_string (to_sexpr_fixstr (source));
   end to_string;

   function to_lower (item : in sexpr_string) return sexpr_string is
   begin
      return to_sexpr_string (to_lower (to_sexpr_fixstr (item)));
   end to_lower;

   function to_upper (item : in sexpr_string) return sexpr_string is
   begin
      return to_sexpr_string (to_upper (to_sexpr_fixstr (item)));
   end to_upper;

   function hash_sexpr_string
     (key : in sexpr_string) return ada.containers.hash_type is
   begin
      return ada.strings.wide_wide_hash (to_wide_wide_string (key));
   end hash_sexpr_string;

   function unrecognized_hash_token_message
     (token : in sexpr_string) return string is
   begin
      return ("unrecognized hash token '#" & to_string (token) & "'");
   end unrecognized_hash_token_message;

   --
   -- to_inexact_real:
   --
   -- FIXME / IMPORTANT NOTE:
   --
   -- This implementation follows Ada conventions for the floating
   -- point notation. There might be subtle errors that we will have
   -- to fix.
   --
   function to_inexact_real (item : sexpr_string) return inexact_real is
   begin
      return
        inexact_real'value (conv.to_string (to_sexpr_fixstr (item)));
   end to_inexact_real;

   ---------------------------------------------------------------------

   procedure ignore (item : in sexpr) is
   begin
      null;
   end ignore;

   ---------------------------------------------------------------------
   --
   -- The unique null list.
   --

   the_null_list : constant sexpr :=
     make_sexpr (node => (kind => sexpr_kind_null));

   function make_null return sexpr is
   begin
      return the_null_list;
   end make_null;

   ---------------------------------------------------------------------
   --
   -- The unique #f and #t
   --

   function register_boolean (value : in boolean) return sexpr is
   begin
      return
        make_sexpr
          (node => (kind => sexpr_kind_boolean, boolean_val => value));
   end register_boolean;

   the_false_value : constant sexpr := register_boolean (false);
   the_true_value  : constant sexpr := register_boolean (true);

   function make_boolean (item : in boolean) return sexpr is
   begin
      return (if item then the_true_value else the_false_value);
   end make_boolean;

   ---------------------------------------------------------------------
   --
   -- Except by special arrangements, symbols with the same name are
   -- eq to each other. This is arranged by having them be the same
   -- sexpr.
   --
   -- (In actual Schemes, the making of symbols can get notoriously
   -- complicated. Most likely we will not need such complication.)
   --

   protected type symbol_registry_type is
      function contains (key : in sexpr_fixstr) return boolean;
      procedure insert (key : in sexpr_fixstr; value : in sexpr);
      function element (key : in sexpr_fixstr) return sexpr;
   private
      table : sexpr_fixstr_to_sexpr_map;
   end symbol_registry_type;

   protected body symbol_registry_type is

      function contains (key : in sexpr_fixstr) return boolean is
      begin
         return table.contains (key);
      end contains;

      procedure insert (key : in sexpr_fixstr; value : in sexpr) is
      begin
         table.insert (key, value);
      end insert;

      function element (key : in sexpr_fixstr) return sexpr is
      begin
         return table.element (key);
      end element;

   end symbol_registry_type;

   symbol_registry : symbol_registry_type;

   function register_new_symbol (source : in sexpr_string) return sexpr
   is
      node : node_record :=
        (kind => sexpr_kind_symbol, symbol_val => source);
   begin
      return result : sexpr := make_sexpr (node) do
         symbol_registry.insert (to_sexpr_fixstr (source), result);
      end return;
   end register_new_symbol;

   function make_symbol (source : in sexpr_string) return sexpr is
      src : sexpr_fixstr := to_sexpr_fixstr (source);
   begin
      return
        (if symbol_registry.contains (src)
         then symbol_registry.element (src)
         else register_new_symbol (source));
   end make_symbol;

   function make_symbol (source : in sexpr_fixstr) return sexpr is
   begin
      return make_symbol (to_sexpr_string (source));
   end make_symbol;

   ---------------------------------------------------------------------

   function make_integer (item : in bignum_integer) return sexpr is
   begin
      return
        make_sexpr ((kind => sexpr_kind_integer, integer_val => item));
   end make_integer;

   function make_inexact (item : in inexact_real) return sexpr is
   begin
      return
        make_sexpr ((kind => sexpr_kind_inexact, inexact_val => item));
   end make_inexact;

   function make_exact (item : in exact_real) return sexpr is
   begin
      return
        make_sexpr
          ((kind => sexpr_kind_rational, rational_val => item));
   end make_exact;

   function make_exact
     (numerator, denominator : in bignum_integer) return sexpr is
   begin
      return make_exact (exact_reals."/" (numerator, denominator));
   end make_exact;

   function make_character (item : in sexpr_character) return sexpr is
   begin
      return
        make_sexpr
          ((kind => sexpr_kind_character, character_val => item));
   end make_character;

   function make_string (source : in sexpr_string) return sexpr is
   begin
      return
        make_sexpr ((kind => sexpr_kind_string, string_val => source));
   end make_string;

   function make_string (source : in sexpr_fixstr) return sexpr is
   begin
      return make_string (to_sexpr_string (source));
   end make_string;

   function to_exact (item : in sexpr) return sexpr is
      result : sexpr;
   begin
      case kind (item) is
         when sexpr_kind_integer | sexpr_kind_rational =>
            result := item;

         when sexpr_kind_inexact                       =>
            result :=
              make_exact (get_numerator (item), get_denominator (item));

         when others                                   =>
            -- FIXME: MORE CONTEXT
            raise type_error with "to_exact";
      end case;
      return result;
   end to_exact;

   function to_inexact (item : in sexpr) return sexpr is
      result : sexpr;
   begin
      case kind (item) is
         when sexpr_kind_integer | sexpr_kind_rational =>
            result := make_inexact (get_inexact (item));

         when sexpr_kind_inexact                       =>
            result := item;

         when others                                   =>
            -- FIXME: MORE CONTEXT
            raise type_error with "to_inexact";
      end case;
      return result;
   end to_inexact;

   function cons (car, cdr : in sexpr) return sexpr is
   begin
      node_registry.increment_reference_count (car.identifier);
      node_registry.increment_reference_count (cdr.identifier);
      return
        make_sexpr
          ((kind     => sexpr_kind_pair,
            pair_val => [car.identifier, cdr.identifier]));
   end cons;

   function make_list (source : in sexpr_vector'class) return sexpr is
   begin
      return result : sexpr := make_null do
         for each of reverse source loop
            result := cons (each, result);
         end loop;
      end return;
   end make_list;

   function make_circular_list
     (source : in sexpr_vector'class) return sexpr
   is
      result : sexpr;
      last   : sexpr;
   begin
      case source.length is
         when 0      =>
            raise type_error
              with "attempt to make an empty circular list";

         when 1      =>
            result := cons (source.first_element, make_null);
            set_cdr (result, result);

         when others =>
            last := cons (source.last_element, make_null);
            result := last;
            for i in reverse source.first_index .. source.last_index - 1
            loop
               result := cons (source (i), result);
            end loop;
            set_cdr (last, result);
      end case;
      return result;
   end make_circular_list;

   function make_vector (source : in sexpr_vector'class) return sexpr is
      node_data : sexpr_identifier_vector;
   begin
      for each of source loop
         node_registry.increment_reference_count (each.identifier);
         node_data.append (each.identifier);
      end loop;
      return
        make_sexpr
          ((kind => sexpr_kind_vector, vector_val => node_data));
   end make_vector;

   function make_bytevector (source : in unsigned_8_vector) return sexpr
   is
      node_data : unsigned_8_vector;
   begin
      --
      -- Make a COPY of the data.
      --
      for each of source loop
         node_data.append (each);
      end loop;
      return
        make_sexpr
          ((kind           => sexpr_kind_bytevector,
            bytevector_val => node_data));
   end make_bytevector;

   ---------------------------------------------------------------------

   function kind (item : in sexpr_identifier) return sexpr_kind is
   begin
      return get_node (item).kind;
   end kind;

   function kind (item : in sexpr) return sexpr_kind is
   begin
      return get_node (item).kind;
   end kind;

   function is_null (item : in sexpr) return boolean is
   begin
      return kind (item) = sexpr_kind_null;
   end is_null;

   function is_boolean (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_boolean);
   end is_boolean;

   function is_integer (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_integer);
   end is_integer;

   function is_inexact (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_inexact);
   end is_inexact;

   function is_exact (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_rational);
   end is_exact;

   function is_number (item : in sexpr) return boolean is
   begin
      return
        (kind (item)
         in sexpr_kind_integer
          | sexpr_kind_inexact
          | sexpr_kind_rational);
   end is_number;

   function is_character (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_character);
   end is_character;

   function is_string (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_string);
   end is_string;

   function is_symbol (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_symbol);
   end is_symbol;

   function is_pair (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_pair);
   end is_pair;

   function is_list (item : in sexpr) return boolean is
      -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
      -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
      -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
      -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
      -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
      -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
      --
      -- This is a naive method for detecting a circular list. Anyway,
      -- we want to do the SRFI-1 classification into the three types
      -- of list.
      --
      cur    : sexpr := item;
      result : boolean := false;
      cnt    : natural := 0;
   begin
      while is_pair (cur) and cnt < 1000000 loop
         cur := cdr (@);
         cnt := @ + 1;
      end loop;
      result := is_null (cur);
      return result;
   end is_list;

   function is_vector (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_vector);
   end is_vector;

   function is_bytevector (item : in sexpr) return boolean is
   begin
      return (kind (item) = sexpr_kind_bytevector);
   end is_bytevector;

   ---------------------------------------------------------------------

   function get_boolean (item : in sexpr) return boolean is
   begin
      if kind (item) /= sexpr_kind_boolean then
         raise type_error with "expected boolean s-expression";
      end if;
      return get_node (item).boolean_val;
   end get_boolean;

   function get_integer (item : in sexpr) return bignum_integer is
   begin
      if kind (item) /= sexpr_kind_integer then
         raise type_error with "expected integer s-expression";
      end if;
      return get_node (item).integer_val;
   end get_integer;

   function get_inexact (item : in sexpr) return inexact_real is
      result : inexact_real;
   begin
      case kind (item) is
         when sexpr_kind_inexact  =>
            result := get_node (item).inexact_val;

         when sexpr_kind_integer  =>
            result :=
              from_big_real (to_big_real (get_node (item).integer_val));

         when sexpr_kind_rational =>
            result := from_big_real (get_node (item).rational_val);

         when others              =>
            -- FIXME: NEED A BETTER ERROR MESSAGE.
            raise type_error with "expected real s-expression";
      end case;
      return result;
   end get_inexact;

   function get_exact (item : in sexpr) return exact_real is
      result : exact_real;
   begin
      case kind (item) is
         when sexpr_kind_inexact  =>
            result := to_big_real (get_node (item).inexact_val);

         when sexpr_kind_integer  =>
            result := to_big_real (get_node (item).integer_val);

         when sexpr_kind_rational =>
            result := get_node (item).rational_val;

         when others              =>
            -- FIXME: NEED A BETTER ERROR MESSAGE.
            raise type_error with "expected real s-expression";
      end case;
      return result;
   end get_exact;

   --
   -- get_numerator:
   --
   -- This is a permissive implementation that does type conversions.
   --
   function get_numerator (item : in sexpr) return bignum_integer is
      result : bignum_integer;
   begin
      case kind (item) is
         when sexpr_kind_inexact  =>
            result :=
              numerator (to_big_real (get_node (item).inexact_val));

         when sexpr_kind_integer  =>
            result := get_node (item).integer_val;

         when sexpr_kind_rational =>
            result := numerator (get_node (item).rational_val);

         when others              =>
            -- FIXME: NEED A BETTER ERROR MESSAGE.
            raise type_error with "expected real s-expression";
      end case;
      return result;
   end get_numerator;

   --
   -- get_denominator:
   --
   -- This is a permissive implementation that does type conversions.
   --
   function get_denominator (item : in sexpr) return bignum_integer is
      result : bignum_integer;
   begin
      case kind (item) is
         when sexpr_kind_inexact  =>
            result :=
              denominator (to_big_real (get_node (item).inexact_val));

         when sexpr_kind_integer  =>
            result := 1;

         when sexpr_kind_rational =>
            result := denominator (get_node (item).rational_val);

         when others              =>
            -- FIXME: NEED A BETTER ERROR MESSAGE.
            raise type_error with "expected real s-expression";
      end case;
      return result;
   end get_denominator;

   function get_character (item : in sexpr) return sexpr_character is
   begin
      if kind (item) /= sexpr_kind_character then
         raise type_error with "expected character s-expression";
      end if;
      return get_node (item).character_val;
   end get_character;

   function get_string (item : in sexpr) return sexpr_string is
   begin
      if kind (item) /= sexpr_kind_string then
         raise type_error with "expected string s-expression";
      end if;
      return get_node (item).string_val;
   end get_string;

   function get_symbol (item : in sexpr) return sexpr_string is
   begin
      if kind (item) /= sexpr_kind_symbol then
         raise type_error with "expected symbol s-expression";
      end if;
      return get_node (item).symbol_val;
   end get_symbol;

   function car (item : in sexpr) return sexpr is
      identifier : sexpr_identifier;
   begin
      if kind (item) /= sexpr_kind_pair then
         raise type_error with "expected pair s-expression";
      end if;
      identifier := get_node (item).pair_val.first_element;
      node_registry.increment_reference_count (identifier);
      return (controlled with identifier => identifier);
   end car;

   function cdr (item : in sexpr) return sexpr is
      identifier : sexpr_identifier;
      vec        : sexpr_identifier_vector;
   begin
      if kind (item) /= sexpr_kind_pair then
         raise type_error with "expected pair s-expression";
      end if;
      vec := get_node (item).pair_val;
      identifier := vec.element (vec.first_index + 1);
      node_registry.increment_reference_count (identifier);
      return (controlled with identifier => identifier);
   end cdr;

   function caar (item : in sexpr) return sexpr is
   begin
      return car (car (item));
   end caar;

   function cadr (item : in sexpr) return sexpr is
   begin
      return car (cdr (item));
   end cadr;

   function cdar (item : in sexpr) return sexpr is
   begin
      return cdr (car (item));
   end cdar;

   function cddr (item : in sexpr) return sexpr is
   begin
      return cdr (cdr (item));
   end cddr;

   function length (item : in sexpr) return count_type is
      current : sexpr := item;
      count   : count_type := 0;
   begin
      while is_pair (current) loop
         count := @ + 1;
         current := cdr (@);
      end loop;
      return count;
   end length;

   function list_ref (item : in sexpr; index : in positive) return sexpr
   is
      current  : sexpr := item;
      position : positive := 1;
      result   : sexpr;
   begin
      while position < index and then is_pair (current) loop
         current := cdr (@);
         position := @ + 1;
      end loop;
      if is_pair (current) then
         result := car (current);
      else
         raise type_error with "list_ref index out of bounds";
      end if;
      return result;
   end list_ref;

   procedure set_car_or_cdr (pair, value : in sexpr; index : in integer)
   with pre => index in 1 | 2
   is
      vec            : sexpr_identifier_vector;
      old_identifier : sexpr_identifier;
   begin
      if kind (pair) /= sexpr_kind_pair then
         raise type_error with "cannot set_car or set_cdr a non-pair";
      else
         vec := get_node (pair).pair_val;
         old_identifier := vec.element (index);
         if value.identifier /= old_identifier then
            node_registry.increment_reference_count (value.identifier);
            vec.insert (index, value.identifier);
            node_registry.decrement_reference_count (old_identifier);
         end if;
      end if;
   end set_car_or_cdr;

   procedure set_car (pair, value : in sexpr) is
   begin
      set_car_or_cdr (pair, value, 1);
   end set_car;

   procedure set_cdr (pair, value : in sexpr) is
   begin
      set_car_or_cdr (pair, value, 2);
   end set_cdr;

   function vector_length (item : in sexpr) return count_type is
   begin
      if kind (item) /= sexpr_kind_vector then
         raise type_error with "vector_length called on a non-vector";
      end if;
      return get_node (item).vector_val.length;
   end vector_length;

   function vector_ref
     (item : in sexpr; index : in positive) return sexpr
   is
      identifier : sexpr_identifier;
   begin
      if kind (item) /= sexpr_kind_vector then
         raise type_error with "vector_ref called on a non-vector";
      end if;
      identifier := get_node (item).vector_val.element (index);
      node_registry.increment_reference_count (identifier);
      return (controlled with identifier => identifier);
   end vector_ref;

   function bytevector_length (item : in sexpr) return count_type is
   begin
      if kind (item) /= sexpr_kind_bytevector then
         raise type_error
           with "bytevector_length called on a non-bytevector";
      end if;
      return get_node (item).bytevector_val.length;
   end bytevector_length;

   function bytevector_ref
     (item : in sexpr; index : in positive) return interfaces.unsigned_8
   is
   begin
      if kind (item) /= sexpr_kind_bytevector then
         raise type_error
           with "bytevector_ref called on a non-bytevector";
      end if;
      return get_node (item).bytevector_val.element (index);
   end bytevector_ref;

   function equal_pairs (left, right : in sexpr) return boolean is
   begin
      return
        equal (car (left), car (right))
        and then equal (cdr (left), cdr (right));
   end equal_pairs;

   function equal_vectors (left, right : in sexpr) return boolean is
      len    : count_type := vector_length (left);
      result : boolean := true;
      index  : positive := 1;
   begin
      if len /= vector_length (right) then
         result := false;
      else
         while index <= integer (len) and result loop
            if not equal
                     (vector_ref (left, index),
                      vector_ref (right, index))
            then
               result := false;
            end if;
            index := @ + 1;
         end loop;
      end if;
      return result;
   end equal_vectors;

   function equal_bytevectors (left, right : in sexpr) return boolean is
      len    : count_type := vector_length (left);
      result : boolean := true;
      index  : positive := 1;
   begin
      if len /= vector_length (right) then
         result := false;
      else
         while index <= integer (len) and result loop
            if bytevector_ref (left, index)
              /= bytevector_ref (right, index)
            then
               result := false;
            end if;
            index := @ + 1;
         end loop;
      end if;
      return result;
   end equal_bytevectors;

   function real_numbers_are_equal
     (a  : in sexpr;
      ka : in sexpr_kind;
      b  : in sexpr;
      kb : in sexpr_kind) return boolean
   with
     pre =>
       ka
       in sexpr_kind_integer | sexpr_kind_inexact | sexpr_kind_rational
       and kb
           in sexpr_kind_integer
            | sexpr_kind_inexact
            | sexpr_kind_rational
   is
      node_a : node_record := get_node (a);
      node_b : node_record := get_node (b);
      result : boolean;
   begin
      case ka is
         when sexpr_kind_integer  =>
            case kb is
               when sexpr_kind_integer  =>
                  result := (node_a.integer_val = node_b.integer_val);

               when sexpr_kind_inexact  =>
                  result :=
                    (to_big_real (node_a.integer_val)
                     = to_big_real (node_b.inexact_val));

               when sexpr_kind_rational =>
                  result :=
                    (to_big_real (node_a.integer_val)
                     = node_b.rational_val);

               when others              =>
                  raise type_error with "internal error";
            end case;

         when sexpr_kind_inexact  =>
            case kb is
               when sexpr_kind_integer  =>
                  result :=
                    (to_big_real (node_a.inexact_val)
                     = to_big_real (node_b.integer_val));

               when sexpr_kind_inexact  =>
                  result := (node_a.inexact_val = node_b.inexact_val);

               when sexpr_kind_rational =>
                  result :=
                    (to_big_real (node_a.inexact_val)
                     = node_b.rational_val);

               when others              =>
                  raise type_error with "internal error";
            end case;

         when sexpr_kind_rational =>
            case kb is
               when sexpr_kind_integer  =>
                  result :=
                    (node_a.rational_val
                     = to_big_real (node_b.integer_val));

               when sexpr_kind_inexact  =>
                  result :=
                    (node_a.rational_val
                     = to_big_real (node_b.inexact_val));

               when sexpr_kind_rational =>
                  result := (node_a.rational_val = node_b.rational_val);

               when others              =>
                  raise type_error with "internal error";
            end case;

         when others              =>
            raise type_error with "internal error";
      end case;
      return result;
   end real_numbers_are_equal;

   function equal (left, right : in sexpr) return boolean is
      kleft  : sexpr_kind := kind (left);
      kright : sexpr_kind := kind (right);
      result : boolean := false;
   begin
      if (kleft
          in sexpr_kind_integer
           | sexpr_kind_inexact
           | sexpr_kind_rational)
        and (kright
             in sexpr_kind_integer
              | sexpr_kind_inexact
              | sexpr_kind_rational)
      then
         result := real_numbers_are_equal (left, kleft, right, kright);
      elsif kleft /= kright then
         result := false;
      else
         case kleft is
            when sexpr_kind_null       =>
               result := true;

            when sexpr_kind_boolean    =>
               result :=
                 (get_node (left).boolean_val
                  = get_node (right).boolean_val);

            when sexpr_kind_character  =>
               result :=
                 (get_node (left).character_val
                  = get_node (right).character_val);

            when sexpr_kind_string     =>
               result :=
                 (get_node (left).string_val
                  = get_node (right).string_val);

            when sexpr_kind_symbol     =>
               result :=
                 (get_node (left).symbol_val
                  = get_node (right).symbol_val);

            when sexpr_kind_pair       =>
               result := equal_pairs (left, right);

            when sexpr_kind_vector     =>
               result := equal_vectors (left, right);

            when sexpr_kind_bytevector =>
               result := equal_bytevectors (left, right);

            when sexpr_kind_integer
               | sexpr_kind_inexact
               | sexpr_kind_rational   =>
               raise type_error with "internal error";
         end case;
      end if;
      return result;
   end equal;

   --
   -- FIXME: CHECK THAT THIS IS DOING THE CORRECT THING. I do not use
   -- eqv much, if ever, so would have to look this up.
   --
   function eqv (left : in sexpr; right : in sexpr) return boolean is
   begin
      return equal (left, right);
   end eqv;

   function assoc (key : in sexpr; alist : in sexpr) return sexpr is
      cur   : sexpr := alist;
      res   : sexpr := make_null;
      found : boolean := false;
      elem  : sexpr;
   begin
      while is_pair (cur) and not found loop
         elem := car (cur);
         if is_pair (elem) and then equal (car (elem), key) then
            res := elem;
            found := true;
         end if;
         cur := cdr (@);
      end loop;
      return res;
   end assoc;

   function assq (key : in sexpr_fixstr; alist : in sexpr) return sexpr
   is
   begin
      return assoc (make_symbol (key), alist);
   end assq;

   function acons
     (key : in sexpr; val : in sexpr; alist : in sexpr) return sexpr
   is
      p   : sexpr := cons (key, val);
      res : sexpr := cons (p, alist);
   begin
      return res;
   end acons;

   function treated_as_whitespace
     (item : in sexpr_character) return boolean is
   begin
      return
        is_space (item)
        or item = sexpr_tab
        or item = sexpr_newline
        or item = sexpr_return
        or item = sexpr_page;
   end treated_as_whitespace;

   function match_two
     (item   : in sexpr_character;
      ctx    : in out parse_context;
      first  : in sexpr_character;
      second : in sexpr_character) return boolean is
   begin
      return (item = first and then peek_next_char (ctx) = second);
   end match_two;

   function peek_two
     (ctx    : in out parse_context;
      first  : in sexpr_character;
      second : in sexpr_character) return boolean is
   begin
      return match_two (peek_char (ctx), ctx, first, second);
   end peek_two;

   function parse_datum (ctx : in out parse_context) return sexpr;

   procedure skip_line_comment (ctx : in out parse_context) is
      ch : sexpr_character := peek_char (ctx);
   begin
      while not is_eof (ctx)
        and then ch /= sexpr_newline
        and then ch /= sexpr_return
      loop
         adv_char (ctx);
         ch := peek_char (ctx);
      end loop;
   end skip_line_comment;

   procedure skip_nested_comment (ctx : in out parse_context) is
      depth : natural := 1;
   begin
      adv_char (ctx); -- skip '#'
      adv_char (ctx); -- skip '|'
      while not is_eof (ctx) and then depth > 0 loop
         if peek_two (ctx, '#', '|') then
            depth := depth + 1;
            adv_char (ctx);
            adv_char (ctx);
         elsif peek_two (ctx, '|', '#') then
            depth := depth - 1;
            adv_char (ctx);
            adv_char (ctx);
         else
            adv_char (ctx);
         end if;
      end loop;
   end skip_nested_comment;

   procedure skip_whitespace_and_comments (ctx : in out parse_context)
   is
      changed : boolean := true;
      c       : sexpr_character;
   begin
      while not is_eof (ctx) and changed loop
         changed := false;
         c := peek_char (ctx);
         if treated_as_whitespace (c) then
            adv_char (ctx);
            changed := true;
         elsif c = sexpr_character'(';') then
            skip_line_comment (ctx);
            changed := true;
         elsif match_two (c, ctx, '#', '|') then
            -- FIXME: THIS OUGHT TO BE HANDLED AS A HASH TOKEN
            skip_nested_comment (ctx);
            changed := true;
         elsif match_two (c, ctx, '#', ';') then
            -- FIXME: THIS OUGHT TO BE HANDLED AS A HASH TOKEN
            adv_char (ctx);
            adv_char (ctx);
            ignore (parse_datum (ctx));
            changed := true;
         elsif match_two (c, ctx, '#', '!') then
            -- FIXME: THIS IS ACTUALLY FOR DIRECTIVES and also is a hash token
            adv_char (ctx);
            adv_char (ctx);
            while not is_eof (ctx)
              and then not is_delimiter (peek_char (ctx))
            loop
               adv_char (ctx);
            end loop;
            changed := true;
         end if;
      end loop;
   end skip_whitespace_and_comments;

   function parse_hex_digit (c : in sexpr_character) return natural is
      res : natural := 0;
   begin
      if not is_hexadecimal_digit (c) then
         raise parse_error with "invalid hex digit: " & c'img;
      elsif is_ascii_digit (c) then
         res := sexpr_character'pos (c) - sexpr_character'pos ('0');
      elsif is_lower (c) then
         res :=
           sexpr_character'pos (c) - sexpr_character'pos ('a') + 10;
      else
         res :=
           sexpr_character'pos (c) - sexpr_character'pos ('A') + 10;
      end if;
      return res;
   end parse_hex_digit;

   function escape_starts_continuation
     (item : sexpr_character) return boolean is
   begin
      return
        (is_space (item)
         or (item in sexpr_tab | sexpr_newline | sexpr_return));
   end escape_starts_continuation;

   --
   -- FIXME: THIS IMPLEMENTATION DOES NOT VERIFY THE CONTINUATION
   -- SYNTAX IS CORRECT.
   --
   procedure parse_continuation (ctx : in out parse_context) is
   begin
      while not is_eof (ctx)
        and then escape_starts_continuation (peek_char (ctx))
      loop
         adv_char (ctx);
      end loop;
   end parse_continuation;

   function parse_hex_escape (ctx : in out parse_context) return natural
   is
      hex_val : natural := 0;
   begin
      while not is_eof (ctx)
        and then peek_char (ctx) /= ';'
        and then not is_delimiter (peek_char (ctx))
      loop
         hex_val := (hex_val * 16) + parse_hex_digit (peek_char (ctx));
         adv_char (ctx);
      end loop;
      if not is_eof (ctx) and then peek_char (ctx) = ';' then
         adv_char (ctx);
      end if;
      return hex_val;
   end parse_hex_escape;

   procedure parse_string_escape
     (ctx : in out parse_context; buf : in out sexpr_string)
   is
      esc : sexpr_character;
   begin
      if is_eof (ctx) then
         raise parse_error with "unterminated string escape";
      end if;
      esc := peek_char (ctx);
      if escape_starts_continuation (esc) then
         parse_continuation (ctx);
      else
         case esc is
            when 'a'    =>
               buf := @ & sexpr_alarm;
               adv_char (ctx);

            when 'b'    =>
               buf := @ & sexpr_backspace;
               adv_char (ctx);

            when 't'    =>
               buf := @ & sexpr_tab;
               adv_char (ctx);

            when 'n'    =>
               buf := @ & sexpr_newline;
               adv_char (ctx);

            when 'r'    =>
               buf := @ & sexpr_return;
               adv_char (ctx);

            when '"'    =>
               buf := @ & sexpr_character'('"');
               adv_char (ctx);

            when '\'    =>
               buf := @ & sexpr_character'('\');
               adv_char (ctx);

            when '|'    =>
               buf := @ & sexpr_character'('|');
               adv_char (ctx);

            when 'x'    =>
               adv_char (ctx);
               buf := @ & sexpr_character'val (parse_hex_escape (ctx));

            when others =>
               buf := @ & esc;
               adv_char (ctx);
         end case;
      end if;
   end parse_string_escape;

   function parse_string_literal
     (ctx : in out parse_context) return sexpr
   is
      buf : sexpr_string := null_sexpr_string;
      c   : sexpr_character;
   begin
      adv_char (ctx); -- skip opening '"'
      while not is_eof (ctx) and then peek_char (ctx) /= '"' loop
         c := peek_char (ctx);
         if c = '\' then
            adv_char (ctx);
            parse_string_escape (ctx, buf);
         else
            buf := @ & c;
            adv_char (ctx);
         end if;
      end loop;
      if is_eof (ctx) then
         raise parse_error with "unterminated string literal";
      end if;
      adv_char (ctx); -- skip closing '"'
      return make_string (buf);
   end parse_string_literal;

   procedure parse_bar_escape
     (ctx : in out parse_context; buf : in out sexpr_string)
   is
      c   : sexpr_character;
      esc : sexpr_character;
   begin
      while not is_eof (ctx) and then peek_char (ctx) /= '|' loop
         c := peek_char (ctx);
         if c = '\' then
            adv_char (ctx);
            if is_eof (ctx) then
               raise parse_error with "unterminated symbol escape";
            end if;
            esc := peek_char (ctx);
            if esc in '|' | '\' then
               buf := @ & esc;
               adv_char (ctx);
            elsif esc = 'x' then
               adv_char (ctx);
               buf := @ & sexpr_character'val (parse_hex_escape (ctx));
            else
               buf := @ & esc;
               adv_char (ctx);
            end if;
         else
            buf := @ & c;
            adv_char (ctx);
         end if;
      end loop;
      if is_eof (ctx) then
         raise parse_error with "unterminated vertical bar symbol";
      end if;
      adv_char (ctx); -- skip closing '|'
   end parse_bar_escape;

   function parse_vertical_symbol
     (ctx : in out parse_context) return sexpr
   is
      buf : sexpr_string := null_sexpr_string;
      c   : sexpr_character;
   begin
      adv_char (ctx); -- skip opening '|'
      while not is_eof (ctx) and then peek_char (ctx) /= '|' loop
         c := peek_char (ctx);
         if c = '\' then
            adv_char (ctx);
            parse_bar_escape (ctx, buf);
         else
            buf := @ & c;
            adv_char (ctx);
         end if;
      end loop;
      if is_eof (ctx) then
         raise parse_error with "unterminated vertical bar symbol";
      end if;
      adv_char (ctx); -- skip closing '|'
      return make_symbol (buf);
   end parse_vertical_symbol;

   function parse_list_items (ctx : in out parse_context) return sexpr
   is
      result : sexpr := make_null;
   begin
      skip_whitespace_and_comments (ctx);
      if is_eof (ctx) then
         raise parse_error with "unexpected eof in list";
      end if;

      if peek_char (ctx) = ')' then
         adv_char (ctx); -- consume ')'
         result := make_null;
      elsif peek_char (ctx) = '.'
        and then is_delimiter (peek_next_char (ctx))
      then
         adv_char (ctx); -- consume '.'
         skip_whitespace_and_comments (ctx);
         result := parse_datum (ctx);
         skip_whitespace_and_comments (ctx);
         if peek_char (ctx) /= ')' then
            raise parse_error with "expected ')' after dotted cdr";
         end if;
         adv_char (ctx); -- consume ')'
      else
         declare
            head : sexpr := parse_datum (ctx);
            tail : sexpr := parse_list_items (ctx);
         begin
            result := cons (head, tail);
         end;
      end if;
      return result;
   end parse_list_items;

   function make_vector_sexpr (ctx : in out parse_context) return sexpr
   is
      temp_list : sexpr;
      vec_count : count_type := 0;
      current   : sexpr;
      items     : sexpr_vector;
      index     : positive := 1;
   begin
      adv_char (ctx); -- skip '('
      temp_list := parse_list_items (ctx);
      vec_count := length (temp_list);
      items.set_length (vec_count);
      current := temp_list;
      while is_pair (current) loop
         items (index) := car (current);
         index := @ + 1;
         current := cdr (@);
      end loop;
      if not is_null (current) then
         raise parse_error with "a vector cannot be dotted";
      end if;
      return make_vector (items);
   end make_vector_sexpr;

   function is_valid_integer
     (source    : in sexpr_fixstr;
      predicate :
        access function (item : in sexpr_character) return boolean)
      return boolean
   is
      result : boolean;
      i_1    : constant integer := source'first;
      i_n    : constant integer := source'last;
      st     : integer range i_1 .. i_n + 1;
   begin
      if i_n < i_1 then
         result := false;
      else
         st := (if source (i_1) in '-' | '+' then i_1 + 1 else i_1);
         if i_n < st then
            result := false;
         else
            result :=
              (for all ch of source (st .. i_n) => predicate (ch));
         end if;
      end if;
      return result;
   end is_valid_integer;

   function is_valid_integer
     (source : in sexpr_fixstr; radix : in positive) return boolean
   with pre => is_radix (radix)
   is
      result : boolean;
   begin
      case radix is
         when 2      =>
            result := is_valid_integer (source, is_binary_digit'access);

         when 8      =>
            result := is_valid_integer (source, is_octal_digit'access);

         when 10     =>
            result := is_valid_integer (source, is_ascii_digit'access);

         when 16     =>
            result :=
              is_valid_integer (source, is_hexadecimal_digit'access);

         when others =>
            raise parse_error with "internal error";
      end case;
      return result;
   end is_valid_integer;

   function is_valid_integer
     (source : in sexpr_string; radix : in positive) return boolean
   with pre => is_radix (radix)
   is
   begin
      return is_valid_integer (to_sexpr_fixstr (source), radix);
   end is_valid_integer;

   function parse_integer_val
     (source : in sexpr_string; radix : in positive)
      return bignum_integer
   is
      base         : constant bignum_integer := to_big_integer (radix);
      digit        : bignum_integer;
      sign         : bignum_integer;
      unsigned_val : bignum_integer;
      st           : positive;
   begin
      sign := (if element (source, 1) = '-' then -1 else 1);
      st := (if element (source, 1) in '-' | '+' then 2 else 1);
      unsigned_val := 0;
      for i in st .. length (source) loop
         digit :=
           to_big_integer (parse_hex_digit (element (source, i)));
         unsigned_val := (@ * base) + digit;
      end loop;
      return (sign * unsigned_val);
   end parse_integer_val;

   procedure split_fraction
     (tok     : in sexpr_string;
      radix   : in integer;
      num_str : out sexpr_string;
      den_str : out sexpr_string)
   with pre => is_radix (radix)
   is
      slash_pos : natural;
      s, t      : sexpr_string;
   begin
      num_str := null_sexpr_string;
      den_str := null_sexpr_string;
      slash_pos := index (tok, slash);
      if 0 < slash_pos then
         s := unbounded_slice (tok, 1, slash_pos - 1);
         if is_valid_integer (s, radix) then
            t := unbounded_slice (tok, slash_pos + 1, length (tok));
            if is_valid_integer (t, radix) then
               num_str := s;
               den_str := t;
            end if;
         end if;
      end if;
   end split_fraction;

   function parse_what_contains_slash
     (tok : in sexpr_string; radix : in integer) return sexpr
   with pre => is_radix (radix)
   is
      num_str : sexpr_string;
      den_str : sexpr_string;
      n, d    : bignum_integer;
      result  : sexpr;
   begin
      split_fraction (tok, radix, num_str, den_str);
      if length (num_str) /= 0 then
         n := parse_integer_val (num_str, radix);
         d := parse_integer_val (den_str, radix);
         if 0 < d then
            result := make_exact (n, d);
         else
            result := make_symbol (tok);
         end if;
      else
         result := make_symbol (tok);
      end if;
      return result;
   end parse_what_contains_slash;

   function is_inf_or_nan (tok : in sexpr_string) return boolean is
   begin
      return (tok in plus_inf | minus_inf | plus_nan | minus_nan);
   end is_inf_or_nan;

   function parse_number_or_symbol
     (ctx          :
        in out parse_context -- For future use in error messages.
      with unreferenced;
      source       : in sexpr_string;
      radix        : in integer := 10;
      allow_symbol : boolean := true) return sexpr
   with pre => is_radix (radix)
   is
      use ada.exceptions;
      result : sexpr;
   begin
      if is_inf_or_nan (source) then
         raise parse_error
           with to_string (source) & " is not yet implemented";
      elsif is_valid_integer (source, radix) then
         result := make_integer (parse_integer_val (source, radix));
      elsif contains_slash (source) then
         result := parse_what_contains_slash (source, radix);
      else
         begin
            if radix = 10 then
               result := make_inexact (to_inexact_real (source));
            else
               raise parse_error
                 with
                   "inexact notations are supported only for base 10:"
                   & " """
                   & to_string (source)
                   & """";
            end if;
         exception
            when exc : others =>
               if allow_symbol then
                  result := make_symbol (source);
               else
                  reraise_occurrence (exc);
               end if;
         end;
      end if;
      return result;
   end parse_number_or_symbol;

   function make_character_from_hash_token
     (ctx : in out parse_context) return sexpr
   is
      c : sexpr_character := sexpr_nul;
      s : sexpr_string;

      procedure collect_subsequents is
      begin
         while not is_eof (ctx)
           and then is_identifier_subsequent (peek_char (ctx))
         loop
            s := @ & peek_char (ctx);
            adv_char (ctx);
         end loop;
      end collect_subsequents;

   begin
      --
      -- The implementation below takes advantage of this: “x” or “X”
      -- followed by a hexadecimal numeral is always a valid Scheme
      -- identifier.
      --
      adv_char (ctx); -- consume the '\'
      if is_eof (ctx) then

         raise parse_error with "unexpected eof after #\";
      else
         c := peek_char (ctx);
         adv_char (ctx);
         if is_identifier_initial (c) then
            s := null_sexpr_string & c;
            collect_subsequents;
            if length (s) /= 1 then
               if (element (source => s, index => 1) in 'x' | 'X'
                   and not is_eof (ctx))
                 and then (peek_char (ctx) = ';'
                           and (for all ch of
                                  to_sexpr_fixstr
                                    (unbounded_slice
                                       (s, 2, length (s))) =>
                                  is_hexadecimal_digit (ch)))
               then
                  adv_char (ctx);
                  s := "16#" & unbounded_slice (s, 2, length (s)) & "#";
                  c :=
                    sexpr_character'val
                      (natural'value
                         (conv.to_string (to_sexpr_fixstr (s))));
               elsif character_name_lookup.contains
                       (to_sexpr_fixstr (s))
               then
                  c :=
                    sexpr_character'val
                      (character_name_lookup (to_sexpr_fixstr (s)));
               else
                  raise parse_error
                    with
                      "unrecognized character name #\" & to_string (s);
               end if;
            end if;
         end if;
      end if;
      return make_character (c);
   end make_character_from_hash_token;

   function make_boolean_sexpr
     (ctx        : in out parse_context;
      short_form : in sexpr_fixstr;
      long_form  : in sexpr_fixstr;
      value      : in boolean) return sexpr
   is
      result  : sexpr;
      s       : constant sexpr_string := collect_identifier (ctx);
      s_lower : constant sexpr_string := to_lower (s);
   begin
      if s_lower = short_form or s_lower = long_form then
         result := make_boolean (value);
      else
         raise parse_error with unrecognized_hash_token_message (s);
      end if;
      return result;
   end make_boolean_sexpr;

   --
   -- collect_bytevector:
   --
   -- This is a very permissive implementation that lets you write
   -- expressions for the elements. That is not how bytevector
   -- literals work in actual Scheme readers. Scheme readers typically
   -- do not understand s-expressions. They understand tokenization,
   -- handling of directives, etc.
   --
   -- (However, we might want some ways to work around not being an
   -- implementation of Scheme. Being able to use an expression in a
   -- #u8(...) expression may help work around not having means to
   -- create bytevectors with Scheme programming.)
   --
   function collect_bytevector (ctx : in out parse_context) return sexpr
   is
      temp_list : sexpr;
      current   : sexpr;
      bytes     : unsigned_8_vector;
      index     : positive := 1;
      val       : bignum_integer;
   begin
      if is_eof (ctx) or else peek_char (ctx) /= '(' then
         raise parse_error with "expected '(' after #u8";
      end if;
      adv_char (ctx); -- skip '('
      temp_list := parse_list_items (ctx);
      bytes.set_length (length (temp_list));
      current := temp_list;
      while is_pair (current) loop
         val := get_integer (car (current));
         if val < 0 or 255 < val then
            raise parse_error
              with "bytevector element out of range: " & val'img;
         end if;
         bytes (index) := interfaces.unsigned_8 (to_integer (val));
         index := @ + 1;
         current := cdr (@);
      end loop;
      if not is_null (current) then
         raise parse_error with "a bytevector cannot be dotted";
      end if;
      return make_bytevector (bytes);
   end collect_bytevector;

   function make_homogeneous_vector_sexpr
     (ctx : in out parse_context) return sexpr
   is
      result  : sexpr;
      s       : constant sexpr_string := collect_identifier (ctx);
      s_lower : constant sexpr_string := to_lower (s);
   begin
      if s_lower = "u8" then
         result := collect_bytevector (ctx);
      else
         raise parse_error with unrecognized_hash_token_message (s);
      end if;
      return result;
   end make_homogeneous_vector_sexpr;

   procedure analyze_hash_numeral_tag
     (ctx       : in out parse_context;
      radix     : out integer;
      exactness : out numerical_exactness)
   with post => is_radix (radix)
   is

      procedure analyze_possible_exactness_tag is
         c1 : sexpr_character;
      begin
         if is_eof (ctx) then
            -- FIXME: GIVE THIS CONTEXT.
            raise parse_error with "unexpected eof";
         elsif peek_char (ctx) = '#' then
            adv_char (ctx);
            if is_eof (ctx) then
               -- FIXME: GIVE THIS CONTEXT.
               raise parse_error with "unexpected eof";
            else
               c1 := peek_char (ctx);
               adv_char (ctx);
               case to_lower (c1) is
                  when 'e'    =>
                     exactness := numerically_exact;

                  when 'i'    =>
                     exactness := numerically_inexact;

                  when others =>
                     -- FIXME: GIVE THIS SOME CONTEXT.
                     raise parse_error with "unrecognized hash token";
               end case;
            end if;
         end if;
      end analyze_possible_exactness_tag;

      procedure analyze_possible_radix_tag is
         c1 : sexpr_character;
      begin
         if is_eof (ctx) then
            -- FIXME: GIVE THIS CONTEXT.
            raise parse_error with "unexpected eof";
         elsif peek_char (ctx) = '#' then
            adv_char (ctx);
            if is_eof (ctx) then
               -- FIXME: GIVE THIS CONTEXT.
               raise parse_error with "unexpected eof";
            else
               c1 := peek_char (ctx);
               adv_char (ctx);
               case to_lower (c1) is
                  when 'b'    =>
                     radix := 2;

                  when 'o'    =>
                     radix := 8;

                  when 'd'    =>
                     radix := 10;

                  when 'x'    =>
                     radix := 16;

                  when others =>
                     -- FIXME: GIVE THIS SOME CONTEXT.
                     raise parse_error with "unrecognized hash token";
               end case;
            end if;
         end if;
      end analyze_possible_radix_tag;

      c : sexpr_character;

   begin
      exactness := numerical_exactness_unspecified;
      radix := 10;

      c := peek_char (ctx);
      adv_char (ctx);
      case to_lower (c) is
         when 'b'    =>
            radix := 2;
            analyze_possible_exactness_tag;

         when 'o'    =>
            radix := 8;
            analyze_possible_exactness_tag;

         when 'd'    =>
            radix := 10;
            analyze_possible_exactness_tag;

         when 'x'    =>
            radix := 16;
            analyze_possible_exactness_tag;

         when 'e'    =>
            exactness := numerically_exact;
            analyze_possible_radix_tag;

         when 'i'    =>
            exactness := numerically_inexact;
            analyze_possible_radix_tag;

         when others =>
            -- FIXME: GIVE THIS SOME CONTEXT.
            raise parse_error with "unrecognized hash token";
      end case;
   end analyze_hash_numeral_tag;

   function make_hash_numeral_sexpr
     (ctx : in out parse_context) return sexpr
   is
      result    : sexpr;
      radix     : integer;
      exactness : numerical_exactness;
   begin
      analyze_hash_numeral_tag (ctx, radix, exactness);
      result :=
        parse_number_or_symbol
          (ctx,
           source       => collect_until_delimiter (ctx),
           radix        => radix,
           allow_symbol => false);
      case exactness is
         when numerical_exactness_unspecified =>
            null;

         when numerically_exact               =>
            result := to_exact (result);

         when numerically_inexact             =>
            result := to_inexact (result);
      end case;
      return result;
   end make_hash_numeral_sexpr;

   function make_datum_label_sexpr
     (ctx : in out parse_context) return sexpr is
   begin
      raise parse_error with "datum labels are not yet implemented";
      return make_null;
   end make_datum_label_sexpr;

   function parse_hash_prefix (ctx : in out parse_context) return sexpr
   is
      result : sexpr;
   begin
      adv_char (ctx); -- skip '#'
      if is_eof (ctx) then
         raise parse_error with "unexpected eof after '#'";
      else
         case to_lower (peek_char (ctx)) is
            when '\'                               =>
               result := make_character_from_hash_token (ctx);

            when '('                               =>
               result := make_vector_sexpr (ctx);

            when 't'                               =>
               result := make_boolean_sexpr (ctx, "t", "true", true);

            when 'f'                               =>
               result := make_boolean_sexpr (ctx, "f", "false", false);

            when 'u'                               =>
               result := make_homogeneous_vector_sexpr (ctx);

            when 'b' | 'o' | 'd' | 'x' | 'e' | 'i' =>
               result := make_hash_numeral_sexpr (ctx);

            when '0' .. '9'                        =>
               result := make_datum_label_sexpr (ctx);

            when others                            =>
               raise parse_error
                 with
                   unrecognized_hash_token_message
                     (null_sexpr_string & peek_char (ctx));
         end case;
      end if;
      return result;
   end parse_hash_prefix;

   function parse_datum (ctx : in out parse_context) return sexpr is
      result : sexpr := make_null;
   begin
      skip_whitespace_and_comments (ctx);
      if is_eof (ctx) then
         raise parse_error with "unexpected end of file";
      end if;

      declare
         c : sexpr_character := peek_char (ctx);
      begin
         if c = sexpr_character'('(') then
            adv_char (ctx);
            result := parse_list_items (ctx);
         elsif c = sexpr_character'('"') then
            result := parse_string_literal (ctx);
         elsif c = sexpr_character'('|') then
            result := parse_vertical_symbol (ctx);
         elsif c = sexpr_character'('#') then
            result := parse_hash_prefix (ctx);
         elsif c = sexpr_character'(''') then
            adv_char (ctx);
            declare
               sub : sexpr := parse_datum (ctx);
            begin
               result :=
                 cons (make_symbol ("quote"), cons (sub, make_null));
            end;
         elsif c = sexpr_character'('`') then
            adv_char (ctx);
            declare
               sub : sexpr := parse_datum (ctx);
            begin
               result :=
                 cons
                   (make_symbol ("quasiquote"), cons (sub, make_null));
            end;
         elsif c = sexpr_character'(',') then
            adv_char (ctx);
            if not is_eof (ctx)
              and then peek_char (ctx) = sexpr_character'('@')
            then
               adv_char (ctx);
               declare
                  sub : sexpr := parse_datum (ctx);
               begin
                  result :=
                    cons
                      (make_symbol ("unquote-splicing"),
                       cons (sub, make_null));
               end;
            else
               declare
                  sub : sexpr := parse_datum (ctx);
               begin
                  result :=
                    cons
                      (make_symbol ("unquote"), cons (sub, make_null));
               end;
            end if;
         else
            declare
               tok : sexpr_string := null_sexpr_string;
            begin
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  append (tok, peek_char (ctx));
                  adv_char (ctx);
               end loop;
               result := parse_number_or_symbol (ctx, tok);
            end;
         end if;
      end;
      return result;
   end parse_datum;

   ---------------------------------------------------------------------
   --
   -- Input and deserialization.
   --

   function read_from_string (source : in sexpr_string) return sexpr is
      ctx    : parse_context;
      result : sexpr;
   begin
      ctx.src := source;
      ctx.pos := 1;
      ctx.len := length (ctx.src);
      result := parse_datum (ctx);
      return result;
   end read_from_string;

   function read_from_string (source : in sexpr_fixstr) return sexpr is
   begin
      return read_from_string (to_sexpr_string (source));
   end read_from_string;

   function read_all_from_string
     (source : in sexpr_string) return sexpr_vector
   is
      ctx       : parse_context;
      temp_list : sexpr := make_null;
      count     : natural := 0;
      current   : sexpr;
      result    : sexpr_vector;
   begin
      ctx.src := source;
      ctx.pos := 1;
      ctx.len := length (ctx.src);

      skip_whitespace_and_comments (ctx);
      while not is_eof (ctx) loop
         temp_list := cons (parse_datum (ctx), temp_list);
         count := @ + 1;
         skip_whitespace_and_comments (ctx);
      end loop;

      result.set_length (count_type (count));
      current := temp_list;
      for i in reverse 1 .. count loop
         result.insert (i, car (current));
         current := cdr (@);
      end loop;

      return result;
   end read_all_from_string;

   function read_file_content (filename : in string) return sexpr_string
   is
      file : file_type;
      buf  : sexpr_string := null_sexpr_string;
   begin
      begin
         open (file, in_file, filename);
      exception
         when others =>
            raise io_error
              with "cannot open file for reading: " & filename;
      end;

      while not end_of_file (file) loop
         declare
            line : sexpr_string := to_sexpr_string (get_line (file));
         begin
            append (buf, line);
            append (buf, sexpr_newline);
         end;
      end loop;
      close (file);
      return buf;
   end read_file_content;

   function read (filename : in string) return sexpr is
      content : sexpr_string := read_file_content (filename);
      result  : sexpr := read_from_string (content);
   begin
      return result;
   end read;

   function read_all (filename : in string) return sexpr_vector is
      content : sexpr_string := read_file_content (filename);
   begin
      return read_all_from_string (content);
   end read_all;

   ---------------------------------------------------------------------
   --
   -- Output and serialization
   --

   subtype shared_counts_type is sexpr_identifier_to_natural_map;

   procedure serialize_without_datum_labels
     (item    : in sexpr;
      display : in boolean;
      result  : in out sexpr_string);

   function shared_count
     (shared_counts : shared_counts_type; item : in sexpr_identifier)
      return natural is
   begin
      return
        (if shared_counts.contains (item)
         then shared_counts.element (item)
         else 0);
   end shared_count;

   --
   -- find_shared_structure:
   --
   -- Find shared structure, for serialization with datum labels
   -- (SRFI-38).
   --
   procedure find_shared_structure
     (shared_counts : in out shared_counts_type;
      item          : in sexpr_identifier)
   is
      count    : natural;
      workload : sexpr_identifier_vector;
      subject  : sexpr_identifier;
   begin
      workload.append (item);
      while workload.length /= 0 loop
         subject := workload.last_element;
         declare
            node : node_record := get_node (subject);

            procedure provide_more_work
              (more_work : in sexpr_identifier_vector) is
            begin
               count := shared_count (shared_counts, subject);
               shared_counts.include (subject, count + 1);
               if count = 0 then
                  for each of more_work loop
                     workload.append (each);
                  end loop;
               end if;
            end provide_more_work;
         begin
            workload.delete_last;
            case node.kind is
               when sexpr_kind_pair       =>
                  provide_more_work (node.pair_val);

               when sexpr_kind_vector     =>
                  provide_more_work (node.vector_val);

               when sexpr_kind_bytevector =>
                  count := shared_count (shared_counts, subject);
                  shared_counts.include (subject, count + 1);

               when others                =>
                  null;
            end case;
         end;
      end loop;
   end find_shared_structure;

   function is_shared_or_circular
     (kind : in sexpr_kind; count : in natural) return boolean is
   begin
      return
        (1 < count
         and kind
             in sexpr_kind_pair
              | sexpr_kind_vector
              | sexpr_kind_bytevector);
   end is_shared_or_circular;

   separator_space : constant sexpr_string :=
     to_sexpr_string (sexpr_fixstr'(" "));

   --
   -- Serialization in the style of SRFI-38
   --
   procedure serialize_with_datum_labels
     (shared_counts : in out shared_counts_type;
      item          : in sexpr_identifier;
      display       : in boolean;
      result        : out sexpr_string)
   is
      procedure serialize_pair_contents (car_val, cdr_val : in sexpr_identifier) is
         done   : boolean;
         tail   : sexpr_identifier;
         tcount : natural;
      begin
         result := @ & "(";
         serialize_with_datum_labels
           (shared_counts => shared_counts,
            item          => car_val,
            display       => display,
            result        => result);
         done := false;
         tail := cdr_val;
         while not done and kind (tail) /= sexpr_kind_null loop
            tcount := shared_count (shared_counts, tail);
            if is_shared_or_circular
              (kind => get_node (tail).kind, count => tcount)
               or kind (tail) /= sexpr_kind_pair
            then
               result := @ & " . ";
               serialize_with_datum_labels
                 (shared_counts => shared_counts,
                  item          => tail,
                  display       => display,
                  result        => result);
               done := true;
            else
               result := @ & " ";
               serialize_with_datum_labels
                 (shared_counts => shared_counts,
                  item          => tail,
                  display       => display,
                  result        => result);

               -- The right hand side here is the cdr.
               tail := get_node (@).pair_val.element (2);
            end if;
         end loop;
         result := @ & ")";
      end serialize_pair_contents;

      procedure serialize_vector_contents
        (vector_val : in sexpr_identifier_vector)
      is
         separator       : sexpr_string := null_sexpr_string;
         separator_space : constant sexpr_string :=
           to_sexpr_string (sexpr_fixstr'(" "));
      begin
         result := @ & "#(";
         for each of vector_val loop
            result := @ & separator;
            serialize_with_datum_labels
              (shared_counts => shared_counts,
               item          => each,
               display       => display,
               result        => result);
            separator := separator_space;
         end loop;
         result := @ & ")";
      end serialize_vector_contents;

      procedure serialize_bytevector_contents
        (bytevector_val : in unsigned_8_vector)
      is
         separator : sexpr_string := null_sexpr_string;
      begin
         result := @ & "#u8(";
         for each of bytevector_val loop
            result :=
              @
              & separator
              & to_sexpr_string (trim_left (unsigned_8'image (each)));
            separator := separator_space;
         end loop;
         result := @ & ")";
      end serialize_bytevector_contents;

      procedure serialize_item (item : in sexpr) is
      begin
         case kind (item) is
            when sexpr_kind_pair       =>
               declare
                  node : node_record := get_node (item);
               begin
                  serialize_pair_contents (node.pair_val.element (1),
                                           node.pair_val.element (2));
               end;

            when sexpr_kind_vector     =>
               serialize_vector_contents (get_node (item).vector_val);

            when sexpr_kind_bytevector =>
               serialize_bytevector_contents
                 (get_node (item).bytevector_val);

            when others                =>
               serialize_without_datum_labels
                 (item => item, display => display, result => result);
         end case;
      end serialize_item;

      label_counter : natural := 0;
      label_map     : sexpr_to_natural_map;

      function label_for_assignment (item : sexpr) return natural is
         label : natural;
      begin
         if label_map.contains (item) then
            label := label_map.element (item);
         else
            label := label_counter;
            label_counter := @ + 1;
            label_map.include (item, label);
         end if;
         return label;
      end label_for_assignment;

      printed_set : sexpr_set;
      label       : natural;
      count       : natural;
   begin
      if is_null (item) then
         result := @ & "()";
      else
         count := shared_count (shared_counts, item);
         if is_shared_or_circular
           (kind => get_node (item).kind, count => count)
         then
            if printed_set.contains (item) then
               --
               -- Print #label#
               --
               label := label_map.element (item);
               result :=
                 @
                 & "#"
                 & to_sexpr_string (trim_left (label'img))
                 & "#";
            else
               --
               -- Print #label=<datum>
               --
               label := label_for_assignment (item);
               result :=
                 @
                 & "#"
                 & to_sexpr_string (trim_left (label'img))
                 & "=";
               printed_set.include (item);
               serialize_item (item);
            end if;
         else
            serialize_item (item);
         end if;
      end if;
   end serialize_with_datum_labels;

   procedure serialize_string
     (item    : in sexpr_string;
      display : in boolean;
      result  : in out sexpr_string) is
   begin
      if display then
         append (result, item);
      else
         append (result, '"');
         for i in 1 .. length (item) loop
            declare
               c : sexpr_character := element (item, i);
            begin
               case c is
                  when sexpr_character'('"') =>
                     append (result, "\""");

                  when sexpr_character'('\') =>
                     append (result, "\\");

                  when sexpr_newline         =>
                     append (result, "\n");

                  when sexpr_tab             =>
                     append (result, "\t");

                  when sexpr_return          =>
                     append (result, "\r");

                  when others                =>
                     append (result, c);
               end case;
            end;
         end loop;
         result := @ & sexpr_character'('"');
      end if;
   end serialize_string;

   procedure serialize_character
     (item    : in sexpr_character;
      display : in boolean;
      result  : in out sexpr_string)
   is
      code : natural := sexpr_character'pos (item);
   begin
      if display then
         if code <= 255 then
            append (result, sexpr_character'val (code));
         else
            append (result, '?');
         end if;
      else
         append (result, "#\");
         case code is
            when 32        =>
               append (result, "space");

            when 10        =>
               append (result, "newline");

            when 9         =>
               append (result, "tab");

            when 13        =>
               append (result, "return");

            when 7         =>
               append (result, "alarm");

            when 8         =>
               append (result, "backspace");

            when 27        =>
               append (result, "escape");

            when 0         =>
               append (result, "null");

            when 127       =>
               append (result, "delete");

            when 33 .. 126 =>
               append (result, sexpr_character'val (code));

            when others    =>
               append (result, "x");
               declare
                  hex_str : sexpr_string := to_sexpr_string (code'img);
               begin
                  result :=
                    @
                    & unbounded_slice (hex_str, 2, length (hex_str))
                    & sexpr_fixstr'(";");
               end;
         end case;
      end if;
   end serialize_character;

   procedure serialize_list
     (item    : in sexpr;
      display : in boolean;
      result  : in out sexpr_string)
   is
      current : sexpr := item;
      first   : boolean := true;
   begin
      append (result, '(');
      while is_pair (current) loop
         if not first then
            append (result, ' ');
         end if;
         first := false;
         serialize_without_datum_labels
           (item    => car (current),
            display => display,
            result  => result);
         current := cdr (@);
      end loop;

      if not is_null (current) then
         append (result, " . ");
         serialize_without_datum_labels
           (item => current, display => display, result => result);
      end if;
      append (result, ')');
   end serialize_list;

   procedure serialize_vector
     (item    : in sexpr;
      display : in boolean;
      result  : in out sexpr_string)
   is
      len : natural := vector_length (item);
   begin
      append (result, "#(");
      for index in 1 .. len loop
         if index > 1 then
            append (result, ' ');
         end if;
         serialize_without_datum_labels
           (item    => vector_ref (item, index),
            display => display,
            result  => result);
      end loop;
      append (result, ')');
   end serialize_vector;

   procedure serialize_bytevector
     (item : in sexpr; result : in out sexpr_string)
   is
      len : natural := bytevector_length (item);
   begin
      append (result, "#u8(");
      for index in 1 .. len loop
         if index > 1 then
            append (result, ' ');
         end if;
         declare
            b_val : interfaces.unsigned_8 :=
              bytevector_ref (item, index);
            s_val : sexpr_string := to_sexpr_string (b_val'img);
         begin
            result := @ & unbounded_slice (s_val, 2, length (s_val));
         end;
      end loop;
      result := @ & sexpr_character'(')');
   end serialize_bytevector;

   procedure serialize_without_datum_labels
     (item    : in sexpr;
      display : in boolean;
      result  : in out sexpr_string) is
   begin
      if is_null (item) then
         append (result, "()");
      else
         case kind (item) is
            when sexpr_kind_null       =>
               append (result, "()");

            when sexpr_kind_boolean    =>
               if get_node (item).boolean_val then
                  append (result, "#t");
               else
                  append (result, "#f");
               end if;

            when sexpr_kind_integer    =>
               result :=
                 @
                 & to_sexpr_string
                     (trim_left
                        (to_string (get_node (item).integer_val)));

            when sexpr_kind_inexact    =>
               result :=
                 @
                 & to_sexpr_string
                     (trim_left (get_node (item).inexact_val'img));

            when sexpr_kind_rational   =>
               result :=
                 @
                 & to_sexpr_string
                     (trim_left
                        (to_string
                           (numerator (get_node (item).rational_val))))
                 & '/'
                 & to_sexpr_string
                     (trim_left
                        (to_string
                           (denominator
                              (get_node (item).rational_val))));

            when sexpr_kind_character  =>
               serialize_character
                 (item    => get_node (item).character_val,
                  display => display,
                  result  => result);

            when sexpr_kind_string     =>
               serialize_string
                 (item    => get_node (item).string_val,
                  display => display,
                  result  => result);

            when sexpr_kind_symbol     =>
               append (result, get_node (item).symbol_val);

            when sexpr_kind_pair       =>
               serialize_list
                 (item => item, display => display, result => result);

            when sexpr_kind_vector     =>
               serialize_vector
                 (item => item, display => display, result => result);

            when sexpr_kind_bytevector =>
               serialize_bytevector (item => item, result => result);
         end case;
      end if;
   end serialize_without_datum_labels;

   function write_to_string (item : in sexpr) return sexpr_string is
      shared_counts : sexpr_to_natural_map;
      result        : sexpr_string := null_sexpr_string;
   begin
      find_shared_structure
        (shared_counts => shared_counts, item => item);
      serialize_with_datum_labels
        (shared_counts => shared_counts,
         item          => item,
         display       => false,
         result        => result);
      return result;
   end write_to_string;

   function write_simple_to_string (item : in sexpr) return sexpr_string
   is
      result : sexpr_string := null_sexpr_string;
   begin
      serialize_without_datum_labels
        (item => item, display => false, result => result);
      return result;
   end write_simple_to_string;

   --
   -- FIXME:  PRINT USING FLOYD’S METHOD WITH ... instead of using datum labels.
   --
   function display_to_string (item : in sexpr) return sexpr_string is
      shared_counts : sexpr_to_natural_map;
      result        : sexpr_string := null_sexpr_string;
   begin
      find_shared_structure
        (shared_counts => shared_counts, item => item);
      serialize_with_datum_labels
        (shared_counts => shared_counts,
         item          => item,
         display       => true,
         result        => result);
      return result;
   end display_to_string;

   procedure write_simple (item : in sexpr; filename : in string) is
      file : file_type;
   begin
      begin
         create (file, out_file, filename, form => "WCEM=8");
      exception
         when others =>
            raise io_error
              with "cannot create file for writing: " & filename;
      end;
      put_line (file, to_sexpr_fixstr (write_simple_to_string (item)));
      close (file);
   end write_simple;

   procedure display (item : in sexpr; filename : in string) is
      file : file_type;
   begin
      begin
         create (file, out_file, filename, form => "WCEM=8");
      exception
         when others =>
            raise io_error
              with "cannot create file for writing: " & filename;
      end;
      put_line (file, to_sexpr_fixstr (display_to_string (item)));
      close (file);
   end display;

   ---------------------------------------------------------------------

begin
   initialize_character_name_lookup;
end sexpressions;

--  sexpressions.adb --- R7RS Scheme S-Expression I/O Implementation
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces;
with ada.characters.conversions;
with ada.strings;
with ada.strings.fixed;
with ada.strings.wide_wide_hash;
with ada.wide_wide_text_io;
with ada.containers.indefinite_hashed_maps;
with ada.unchecked_deallocation;

package body sexpressions is

   use interfaces;
   use ada.wide_wide_text_io;
   use bignum_integers;
   use exact_reals;
   use exact_reals_conversions;
   use sexpr_characters_handling;
   use sexpr_strings;

   package conv renames ada.characters.conversions;

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
     sexpr_character'val (11);
   pragma unreferenced (sexpr_vtab);
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

   type label_entry is record
      id  : natural;
      val : sexpr;
   end record;

   -- FIXME: WE SHOULD SUPPORT ANY NUMBER OF LABELS. USE A MAP. The
   -- standard says just that a label should be a sequence of digits.
   -- To be the most GNUish, allow any sequence of digits.
   type label_table_array is array (1 .. 128) of label_entry;

   type label_context is record
      -- FIXME: THIS SHOULD BE IN THE PARSE CONTEXT
      count   : natural := 0;
      entries : label_table_array;
   end record;

   type parse_context is record
      src       : sexpr_string;
      pos       : positive := 1;
      len       : natural := 0;
      fold_case : boolean := false; --------- FIXME: NOT CURRENTLY USED.
      lbl       : label_context;
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
     (ctx : in parse_context) return sexpr_character
   is
      res : sexpr_character := sexpr_nul;
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

   --   --
   --   -- is_identifier:
   --   --
   --   -- Is “source” a valid R⁷RS Scheme identifier?
   --   --
   --   function is_identifier (source : in sexpr_fixstr) return boolean is
   --      is_ident : boolean;
   --   begin
   --      case source'length is
   --         when 0      =>
   --            is_ident := false;
   --
   --         when 1      =>
   --            is_ident := is_identifier_initial (source (source'first));
   --
   --         when others =>
   --            is_ident :=
   --              is_identifier_initial (source (source'first))
   --              and (for all c of
   --                     source (source'first + 1 .. source'last) =>
   --                     is_identifier_subsequent (c));
   --      end case;
   --      return is_ident;
   --   end is_identifier;
   --
   --   --
   --   -- is_x_hexadecimal:
   --   --
   --   -- Is “source” of the form “x101AB;” or similar?
   --   --
   --   function is_x_hexadecimal (source : in sexpr_fixstr) return boolean
   --   is
   --      is_x_hex : boolean;
   --   begin
   --      if source'length <= 3 then
   --         is_x_hex := false;
   --      else
   --         is_x_hex :=
   --           source (source'first) in 'x' | 'X'
   --           and source (source'last) = ';'
   --           and (for all c of
   --                  source (source'first + 1 .. source'last - 1) =>
   --                  is_hexadecimal_digit (c));
   --      end if;
   --      return is_x_hex;
   --   end is_x_hexadecimal;

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
         return not is_delimiter (peek_char (ctx));
      end pred;
   begin
      return collect_while (ctx, predicate => pred'access);
   end collect_until_delimiter;

   function collect_ascii_digits
     (ctx : in out parse_context) return sexpr_string is
   begin
      return collect_while (ctx, predicate => is_ascii_digit'access);
   end collect_ascii_digits;

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

   package sexpr_fixstr_to_integer is new
     ada.containers.indefinite_hashed_maps
       (key_type        => sexpr_fixstr,
        element_type    => integer,
        hash            => hash,
        equivalent_keys => "=");

   character_name_lookup : sexpr_fixstr_to_integer.map;

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

   function hash (key : in sexpr_string) return ada.containers.hash_type
   is
   begin
      return ada.strings.wide_wide_hash (to_wide_wide_string (key));
   end hash;

   function unrecognized_hash_token_message
     (token : in sexpr_string) return string is
   begin
      return ("unrecognized hash token '#'" & to_string (token));
   end unrecognized_hash_token_message;

   --
   -- to_float:
   --
   -- FIXME / IMPORTANT NOTE:
   --
   -- This implementation follows Ada conventions for the floating
   -- point notation. There might be subtle errors that we will have
   -- to fix.
   --
   function to_float (item : sexpr_string) return long_float is
   begin
      return long_float'value (conv.to_string (to_sexpr_fixstr (item)));
   end to_float;

   procedure free_node is new
     ada.unchecked_deallocation (node_record, node_access);

   procedure free_vec is new
     ada.unchecked_deallocation (sexpr_array, sexpr_vector_access);

   procedure free_bytes is new
     ada.unchecked_deallocation (byte_array, byte_vector_access);

   procedure adjust (obj : in out sexpr) is
   begin
      if obj.ptr /= null then
         obj.ptr.ref_count := obj.ptr.ref_count + 1;
      end if;
   end adjust;

   procedure finalize (obj : in out sexpr) is
   begin
      if obj.ptr /= null then
         if obj.ptr.ref_count > 1 then
            obj.ptr.ref_count := obj.ptr.ref_count - 1;
         else
            if obj.ptr.kind = kind_vector
              and then obj.ptr.vector_val /= null
            then
               free_vec (obj.ptr.vector_val);
            elsif obj.ptr.kind = kind_bytevector
              and then obj.ptr.bytevector_val /= null
            then
               free_bytes (obj.ptr.bytevector_val);
            end if;
            free_node (obj.ptr);
         end if;
         obj.ptr := null;
      end if;
   end finalize;

   procedure ignore (item : sexpr) is
   begin
      null;
   end ignore;

   function make_null return sexpr is
      res : sexpr;
   begin
      res.ptr := null;
      return res;
   end make_null;

   function make_boolean (val : in boolean) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_boolean);
      res.ptr.boolean_val := val;
      return res;
   end make_boolean;

   function make_integer (val : in bignum_integer) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_integer);
      res.ptr.integer_val := val;
      return res;
   end make_integer;

   function make_inexact (val : in inexact_real) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_inexact);
      res.ptr.inexact_val := val;
      return res;
   end make_inexact;

   function make_exact (val : in exact_real) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_rational);
      res.ptr.rational_val := val;
      return res;
   end make_exact;

   function make_exact
     (num : in bignum_integer; den : in bignum_integer) return sexpr is
   begin
      return make_exact (exact_reals."/" (num, den));
   end make_exact;

   function make_character (ch : in sexpr_character) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_character);
      res.ptr.character_val := ch;
      return res;
   end make_character;

   function make_string (str : in sexpr_string) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_string);
      res.ptr.string_val := str;
      return res;
   end make_string;

   function make_string (str : in sexpr_fixstr) return sexpr is
   begin
      return make_string (to_sexpr_string (str));
   end make_string;

   function make_symbol (sym : in sexpr_string) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_symbol);
      res.ptr.symbol_val := sym;
      return res;
   end make_symbol;

   function make_symbol (sym : in sexpr_fixstr) return sexpr is
   begin
      return make_symbol (to_sexpr_string (sym));
   end make_symbol;

   function cons (car_val : in sexpr; cdr_val : in sexpr) return sexpr
   is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_pair);
      res.ptr.car_val := car_val;
      res.ptr.cdr_val := cdr_val;
      return res;
   end cons;

   function make_list (items : in sexpr_array) return sexpr is
      res : sexpr := make_null;
   begin
      for idx in reverse items'range loop
         res := cons (items (idx), res);
      end loop;
      return res;
   end make_list;

   function make_vector (items : in sexpr_array) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_vector);
      res.ptr.vector_val := new sexpr_array (1 .. items'length);
      for idx in items'range loop
         res.ptr.vector_val (idx - items'first + 1) := items (idx);
      end loop;
      return res;
   end make_vector;

   function make_bytevector (bytes : in byte_array) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_bytevector);
      res.ptr.bytevector_val := new byte_array (1 .. bytes'length);
      for idx in bytes'range loop
         res.ptr.bytevector_val (idx - bytes'first + 1) := bytes (idx);
      end loop;
      return res;
   end make_bytevector;

   function kind (e : in sexpr) return sexpr_kind is
      res : sexpr_kind := kind_null;
   begin
      if e.ptr /= null then
         res := e.ptr.kind;
      end if;
      return res;
   end kind;

   function is_null (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr = null or else e.ptr.kind = kind_null);
      return res;
   end is_null;

   function is_boolean (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_boolean);
      return res;
   end is_boolean;

   function is_integer (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_integer);
      return res;
   end is_integer;

   function is_inexact (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_inexact);
      return res;
   end is_inexact;

   function is_exact (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_rational);
      return res;
   end is_exact;

   function is_number (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      if e.ptr /= null then
         res :=
           (e.ptr.kind in kind_integer | kind_inexact | kind_rational);
      end if;
      return res;
   end is_number;

   function is_character (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_character);
      return res;
   end is_character;

   function is_string (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_string);
      return res;
   end is_string;

   function is_symbol (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_symbol);
      return res;
   end is_symbol;

   function is_pair (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_pair);
      return res;
   end is_pair;

   function is_list (e : in sexpr) return boolean is
      cur : sexpr := e;
      res : boolean := false;
      cnt : natural := 0;
   begin
      while is_pair (cur) and cnt < 1000000 loop
         cur := cur.ptr.cdr_val;
         cnt := cnt + 1;
      end loop;
      res := is_null (cur);
      return res;
   end is_list;

   function is_vector (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_vector);
      return res;
   end is_vector;

   function is_bytevector (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_bytevector);
      return res;
   end is_bytevector;

   function get_boolean (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_boolean then
         res := e.ptr.boolean_val;
      else
         raise type_error with "expected boolean s-expression";
      end if;
      return res;
   end get_boolean;

   function get_integer (e : in sexpr) return bignum_integer is
      res : bignum_integer := 0;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_integer then
         res := e.ptr.integer_val;
      else
         raise type_error with "expected integer s-expression";
      end if;
      return res;
   end get_integer;

   function get_inexact (e : in sexpr) return inexact_real is
      procedure err is
      begin
         -- FIXME: NEED A BETTER ERROR MESSAGE.
         raise type_error with "expected real s-expression";
      end err;
      res : inexact_real;
   begin
      if e.ptr = null then
         err;
      else
         case e.ptr.kind is
            when kind_inexact  =>
               res := e.ptr.inexact_val;

            when kind_integer  =>
               res := from_big_real (to_big_real (e.ptr.integer_val));

            when kind_rational =>
               res := from_big_real (e.ptr.rational_val);

            when others        =>
               err;
         end case;
      end if;
      return res;
   end get_inexact;

   function get_exact (e : in sexpr) return exact_real is
      procedure err is
      begin
         -- FIXME: NEED A BETTER ERROR MESSAGE.
         raise type_error with "expected real s-expression";
      end err;
      res : exact_real;
   begin
      if e.ptr = null then
         err;
      else
         case e.ptr.kind is
            when kind_inexact  =>
               res := to_big_real (e.ptr.inexact_val);

            when kind_integer  =>
               res := to_big_real (e.ptr.integer_val);

            when kind_rational =>
               res := e.ptr.rational_val;

            when others        =>
               err;
         end case;
      end if;
      return res;
   end get_exact;

   --
   -- get_numerator:
   --
   -- This is a permissive implementation that does type conversions.
   --
   function get_numerator (e : in sexpr) return bignum_integer is
      procedure err is
      begin
         -- FIXME: NEED A BETTER ERROR MESSAGE.
         raise type_error with "expected real s-expression";
      end err;
      res : bignum_integer;
   begin
      if e.ptr = null then
         err;
      else
         case e.ptr.kind is
            when kind_inexact  =>
               res := numerator (to_big_real (e.ptr.inexact_val));

            when kind_integer  =>
               res := e.ptr.integer_val;

            when kind_rational =>
               res := numerator (e.ptr.rational_val);

            when others        =>
               err;
         end case;
      end if;
      return res;
   end get_numerator;

   --
   -- get_denominator:
   --
   -- This is a permissive implementation that does type conversions.
   --
   function get_denominator (e : in sexpr) return bignum_integer is
      procedure err is
      begin
         -- FIXME: NEED A BETTER ERROR MESSAGE.
         raise type_error with "expected real s-expression";
      end err;
      res : bignum_integer;
   begin
      if e.ptr = null then
         err;
      else
         case e.ptr.kind is
            when kind_inexact  =>
               res := denominator (to_big_real (e.ptr.inexact_val));

            when kind_integer  =>
               res := 1;

            when kind_rational =>
               res := denominator (e.ptr.rational_val);

            when others        =>
               err;
         end case;
      end if;
      return res;
   end get_denominator;

   function get_character (e : in sexpr) return sexpr_character is
      res : sexpr_character := ' ';
   begin
      if e.ptr /= null and then e.ptr.kind = kind_character then
         res := e.ptr.character_val;
      else
         raise type_error with "expected character s-expression";
      end if;
      return res;
   end get_character;

   function get_string (e : in sexpr) return sexpr_string is
      res : sexpr_string := null_sexpr_string;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_string then
         res := e.ptr.string_val;
      else
         raise type_error with "expected string s-expression";
      end if;
      return res;
   end get_string;

   function get_symbol (e : in sexpr) return sexpr_string is
      res : sexpr_string := null_sexpr_string;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_symbol then
         res := e.ptr.symbol_val;
      else
         raise type_error with "expected symbol s-expression";
      end if;
      return res;
   end get_symbol;

   function car (e : in sexpr) return sexpr is
      res : sexpr;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_pair then
         res := e.ptr.car_val;
      else
         raise type_error with "expected pair for car";
      end if;
      return res;
   end car;

   function cdr (e : in sexpr) return sexpr is
      res : sexpr;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_pair then
         res := e.ptr.cdr_val;
      else
         raise type_error with "expected pair for cdr";
      end if;
      return res;
   end cdr;

   function caar (e : in sexpr) return sexpr is
      res : sexpr := car (car (e));
   begin
      return res;
   end caar;

   function cadr (e : in sexpr) return sexpr is
      res : sexpr := car (cdr (e));
   begin
      return res;
   end cadr;

   function cdar (e : in sexpr) return sexpr is
      res : sexpr := cdr (car (e));
   begin
      return res;
   end cdar;

   function cddr (e : in sexpr) return sexpr is
      res : sexpr := cdr (cdr (e));
   begin
      return res;
   end cddr;

   function length (e : in sexpr) return natural is
      cur : sexpr := e;
      cnt : natural := 0;
   begin
      while is_pair (cur) loop
         cnt := cnt + 1;
         cur := cur.ptr.cdr_val;
      end loop;
      return cnt;
   end length;

   function list_ref (e : in sexpr; idx : in positive) return sexpr is
      cur : sexpr := e;
      pos : positive := 1;
      res : sexpr;
   begin
      while pos < idx and then is_pair (cur) loop
         cur := cur.ptr.cdr_val;
         pos := pos + 1;
      end loop;
      if is_pair (cur) then
         res := cur.ptr.car_val;
      else
         raise type_error with "list_ref index out of bounds";
      end if;
      return res;
   end list_ref;

   function vector_length (e : in sexpr) return natural is
      res : natural := 0;
   begin
      if e.ptr /= null
        and then e.ptr.kind = kind_vector
        and then e.ptr.vector_val /= null
      then
         res := e.ptr.vector_val'length;
      end if;
      return res;
   end vector_length;

   function vector_ref (e : in sexpr; idx : in positive) return sexpr is
      res : sexpr;
   begin
      if e.ptr /= null
        and then e.ptr.kind = kind_vector
        and then e.ptr.vector_val /= null
        and then idx in e.ptr.vector_val'range
      then
         res := e.ptr.vector_val (idx);
      else
         raise type_error with "vector_ref index out of bounds";
      end if;
      return res;
   end vector_ref;

   function bytevector_length (e : in sexpr) return natural is
      res : natural := 0;
   begin
      if e.ptr /= null
        and then e.ptr.kind = kind_bytevector
        and then e.ptr.bytevector_val /= null
      then
         res := e.ptr.bytevector_val'length;
      end if;
      return res;
   end bytevector_length;

   function bytevector_ref
     (e : in sexpr; idx : in positive) return interfaces.unsigned_8
   is
      res : interfaces.unsigned_8 := 0;
   begin
      if e.ptr /= null
        and then e.ptr.kind = kind_bytevector
        and then e.ptr.bytevector_val /= null
        and then idx in e.ptr.bytevector_val'range
      then
         res := e.ptr.bytevector_val (idx);
      else
         raise type_error with "bytevector_ref index out of bounds";
      end if;
      return res;
   end bytevector_ref;

   function equal_pairs (a : in sexpr; b : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := equal (car (a), car (b)) and then equal (cdr (a), cdr (b));
      return res;
   end equal_pairs;

   function equal_vectors (a : in sexpr; b : in sexpr) return boolean is
      len : natural := vector_length (a);
      res : boolean := true;
      idx : positive := 1;
   begin
      if len /= vector_length (b) then
         res := false;
      else
         while idx <= len and res loop
            if not equal (vector_ref (a, idx), vector_ref (b, idx)) then
               res := false;
            end if;
            idx := idx + 1;
         end loop;
      end if;
      return res;
   end equal_vectors;

   function equal_bytevectors
     (a : in sexpr; b : in sexpr) return boolean
   is
      len : natural := bytevector_length (a);
      res : boolean := true;
      idx : positive := 1;
   begin
      if len /= bytevector_length (b) then
         res := false;
      else
         while idx <= len and res loop
            if bytevector_ref (a, idx) /= bytevector_ref (b, idx) then
               res := false;
            end if;
            idx := idx + 1;
         end loop;
      end if;
      return res;
   end equal_bytevectors;

   function equal (a : in sexpr; b : in sexpr) return boolean is
      ka  : sexpr_kind := kind (a);
      kb  : sexpr_kind := kind (b);
      res : boolean := false;
   begin
      if is_null (a) and is_null (b) then
         res := true;
      elsif ka /= kb then
         res := false;
      else
         case ka is
            when kind_null       =>
               res := true;

            when kind_boolean    =>
               res := (a.ptr.boolean_val = b.ptr.boolean_val);

            when kind_integer    =>
               res := (a.ptr.integer_val = b.ptr.integer_val);

            when kind_inexact    =>
               res := (a.ptr.inexact_val = b.ptr.inexact_val);

            when kind_rational   =>
               res := (a.ptr.rational_val = b.ptr.rational_val);

            when kind_character  =>
               res := (a.ptr.character_val = b.ptr.character_val);

            when kind_string     =>
               res := (a.ptr.string_val = b.ptr.string_val);

            when kind_symbol     =>
               res := (a.ptr.symbol_val = b.ptr.symbol_val);

            when kind_pair       =>
               res := equal_pairs (a, b);

            when kind_vector     =>
               res := equal_vectors (a, b);

            when kind_bytevector =>
               res := equal_bytevectors (a, b);
         end case;
      end if;
      return res;
   end equal;

   function eqv (a : in sexpr; b : in sexpr) return boolean is
   begin
      return equal (a, b);
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
         cur := cdr (cur);
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

   --   function parse_named_char
   --     (name : in sexpr_string) return sexpr_character
   --   is
   --      res : sexpr_character := ' ';
   --      low : sexpr_string := to_lower (name);
   --   begin
   --      if low = "space" then
   --         res := ' ';
   --      elsif low = "newline" then
   --         res := sexpr_newline;
   --      elsif low = "tab" then
   --         res := sexpr_character'val (9);
   --      elsif low = "return" then
   --         res := sexpr_character'val (13);
   --      elsif low = "alarm" then
   --         res := sexpr_character'val (7);
   --      elsif low = "backspace" then
   --         res := sexpr_character'val (8);
   --      elsif low = "escape" then
   --         res := sexpr_character'val (27);
   --      elsif low = "null" then
   --         res := sexpr_nul;
   --      elsif low = "delete" then
   --         res := sexpr_character'val (127);
   --      elsif length (name) = 1 then
   --         res := element (name, 1);
   --      else
   --         raise parse_error with "unknown character name: " & name'img;
   --      end if;
   --      return res;
   --   end parse_named_char;

   --   function parse_character_literal
   --     (ctx : in out parse_context) return sexpr
   --   is
   --      res : sexpr;
   --   begin
   --      adv_char (ctx); -- skip '\'
   --      if is_eof (ctx) then
   --         raise parse_error with "unexpected eof after #\";
   --      end if;
   --
   --      if peek_char (ctx) = 'x'
   --        and then not is_delimiter (peek_next_char (ctx))
   --        and then is_hexadecimal_digit (peek_next_char (ctx))
   --      then
   --         adv_char (ctx); -- skip 'x'
   --         declare
   --            hex_val : natural := 0;
   --         begin
   --            while not is_eof (ctx)
   --              and then peek_char (ctx) /= ';'
   --              and then not is_delimiter (peek_char (ctx))
   --            loop
   --               hex_val :=
   --                 hex_val * 16 + parse_hex_digit (peek_char (ctx));
   --               adv_char (ctx);
   --            end loop;
   --            if not is_eof (ctx) and then peek_char (ctx) = ';' then
   --               adv_char (ctx);
   --            end if;
   --            res := make_character (sexpr_character'val (hex_val));
   --         end;
   --      elsif is_delimiter (peek_char (ctx)) then
   --         declare
   --            ch : sexpr_character := peek_char (ctx);
   --         begin
   --            adv_char (ctx);
   --            res := make_character (ch);
   --         end;
   --      else
   --         declare
   --            tok : sexpr_string := null_sexpr_string;
   --         begin
   --            while not is_eof (ctx)
   --              and then not is_delimiter (peek_char (ctx))
   --            loop
   --               append (tok, peek_char (ctx));
   --               adv_char (ctx);
   --            end loop;
   --            res := make_character (parse_named_char (tok));
   --         end;
   --      end if;
   --      return res;
   --   end parse_character_literal;

   function parse_list_items (ctx : in out parse_context) return sexpr
   is
      res : sexpr := make_null;
   begin
      skip_whitespace_and_comments (ctx);
      if is_eof (ctx) then
         raise parse_error with "unexpected eof in list";
      end if;

      if peek_char (ctx) = ')' then
         adv_char (ctx); -- consume ')'
         res := make_null;
      elsif peek_char (ctx) = '.'
        and then is_delimiter (peek_next_char (ctx))
      then
         adv_char (ctx); -- consume '.'
         skip_whitespace_and_comments (ctx);
         res := parse_datum (ctx);
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
            res := cons (head, tail);
         end;
      end if;
      return res;
   end parse_list_items;

   function make_vector_sexpr (ctx : in out parse_context) return sexpr
   is
      temp_list : sexpr;
      vec_count : natural := 0;
      cur       : sexpr;
      res       : sexpr;
   begin
      ------------------------------------------------ FIXME: FIND OUT WHAT HAPPENS IF THE LIST IS DOTTED.
      adv_char (ctx); -- skip '('
      temp_list := parse_list_items (ctx);
      vec_count := length (temp_list);

      declare
         items : sexpr_array (1 .. vec_count);
         idx   : positive := 1;
      begin
         cur := temp_list;
         while is_pair (cur) loop
            items (idx) := car (cur);
            idx := idx + 1;
            cur := cdr (cur);
         end loop;
         res := make_vector (items);
      end;
      return res;
   end make_vector_sexpr;

   function is_valid_integer
     (source    : in sexpr_fixstr;
      predicate :
        access function (item : in sexpr_character) return boolean)
      return boolean
   is
      res : boolean;
      i_1 : constant integer := source'first;
      i_n : constant integer := source'last;
      st  : integer range i_1 .. i_n + 1;
   begin
      if i_n < i_1 then
         res := false;
      else
         st := (if source (i_1) in '-' | '+' then i_1 + 1 else i_1);
         if i_n < st then
            res := false;
         else
            res := (for all ch of source (st .. i_n) => predicate (ch));
         end if;
      end if;
      return res;
   end is_valid_integer;

   function is_valid_integer
     (source : in sexpr_fixstr; radix : in positive) return boolean
   with pre => is_radix (radix)
   is
      res : boolean;
   begin
      case radix is
         when 2      =>
            res := is_valid_integer (source, is_binary_digit'access);

         when 8      =>
            res := is_valid_integer (source, is_octal_digit'access);

         when 10     =>
            res := is_valid_integer (source, is_ascii_digit'access);

         when 16     =>
            res :=
              is_valid_integer (source, is_hexadecimal_digit'access);

         when others =>
            raise parse_error with "internal error";
      end case;
      return res;
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
      res     : sexpr;
   begin
      split_fraction (tok, radix, num_str, den_str);
      if length (num_str) /= 0 then
         n := parse_integer_val (num_str, radix);
         d := parse_integer_val (den_str, radix);
         if 0 < d then
            res := make_exact (n, d);
         else
            res := make_symbol (tok);
         end if;
      else
         res := make_symbol (tok);
      end if;
      return res;
   end parse_what_contains_slash;

   function is_inf_or_nan (tok : in sexpr_string) return boolean is
   begin
      return (tok in plus_inf | minus_inf | plus_nan | minus_nan);
   end is_inf_or_nan;

   function parse_number_or_symbol
     (raw_tok : in sexpr_string; radix : in integer := 10) return sexpr
   with pre => is_radix (radix)
   is
      tok : sexpr_string := raw_tok;
      res : sexpr;
   begin
      if is_inf_or_nan (tok) then
         raise parse_error
           with to_string (tok) & " is not yet implemented";
      elsif is_valid_integer (tok, radix) then
         res := make_integer (parse_integer_val (tok, radix));
      elsif contains_slash (tok) then
         res := parse_what_contains_slash (tok, radix);
      else
         begin
            res := make_inexact (to_float (tok));
         exception
            when others =>
               res := make_symbol (tok);
         end;
      end if;
      return res;
   end parse_number_or_symbol;

   function collect_datum_label
     (ctx : in out parse_context) return sexpr_string
   is
      s : sexpr_string := null_sexpr_string;
   begin
      -- Collects a datum label, without the assignment (if there is
      -- an assignment).
      adv_char (ctx);
      while not is_eof (ctx)
        and then (not is_delimiter (peek_char (ctx))
                  and peek_char (ctx) /= '#')
      loop
         s := @ & peek_char (ctx);
         adv_char (ctx);
      end loop;
      if not is_eof (ctx) and then peek_char (ctx) = '#' then
         s := @ & '#';
      else
         raise parse_error
           with "datum label error: """ & to_string (s) & """";
      end if;
      return s;
   end collect_datum_label;

   function collect_hash_token_start
     (ctx : in out parse_context) return sexpr_string
   is
      s : sexpr_string := null_sexpr_string;
   begin
      if not is_eof (ctx) then
         if peek_char (ctx) in '\' | '(' then
            s := @ & peek_char (ctx);
            adv_char (ctx);
         elsif is_ascii_digit (peek_char (ctx)) then
            s := collect_datum_label (ctx);
         else
            s := collect_until_delimiter (ctx);
         end if;
      end if;
      return s;
   end collect_hash_token_start;

   prefixes_exactnumbers : constant sexpr_string_array :=
     [to_sexpr_string (sexpr_fixstr'("e#b")),
      to_sexpr_string (sexpr_fixstr'("b#e")),
      to_sexpr_string (sexpr_fixstr'("e#o")),
      to_sexpr_string (sexpr_fixstr'("o#e")),
      to_sexpr_string (sexpr_fixstr'("e#d")),
      to_sexpr_string (sexpr_fixstr'("d#e")),
      to_sexpr_string (sexpr_fixstr'("e#x")),
      to_sexpr_string (sexpr_fixstr'("x#e"))];

   prefixes_inexactnumbers : constant sexpr_string_array :=
     [to_sexpr_string (sexpr_fixstr'("i#b")),
      to_sexpr_string (sexpr_fixstr'("b#i")),
      to_sexpr_string (sexpr_fixstr'("i#o")),
      to_sexpr_string (sexpr_fixstr'("o#i")),
      to_sexpr_string (sexpr_fixstr'("i#d")),
      to_sexpr_string (sexpr_fixstr'("d#i")),
      to_sexpr_string (sexpr_fixstr'("i#x")),
      to_sexpr_string (sexpr_fixstr'("x#i"))];

   prefixes_numbers : constant sexpr_string_array :=
     [to_sexpr_string (sexpr_fixstr'("b")),
      to_sexpr_string (sexpr_fixstr'("o")),
      to_sexpr_string (sexpr_fixstr'("d")),
      to_sexpr_string (sexpr_fixstr'("x"))];

   function is_numeral_prefix_character
     (item : in sexpr_character) return boolean is
   begin
      return item in 'b' | 'o' | 'd' | 'x' | '#';
   end is_numeral_prefix_character;

   procedure split_at_numeral_prefix
     (source : in sexpr_string;
      prefix : out sexpr_string;
      other  : out sexpr_string)
   is
      n : natural := length (source);
      i : integer range 1 .. n + 1 := 1;

      procedure handle_case (in_array : sexpr_character_array) is
      begin
         i := @ + 1;
         if i /= n + 1 then
            if is_numeral_prefix_character (element (source, i)) then
               prefix := unbounded_slice (source, 1, i - 1);
               other := unbounded_slice (source, i, n);
            elsif (element (source, i) = '#' and i + 2 /= n + 1)
              and then (is_member (element (source, i + 1), in_array)
                        and is_numeral_prefix_character
                              (element (source, i + 2)))
            then
               prefix := unbounded_slice (source, 1, i + 1);
               other := unbounded_slice (source, i + 2, n);
            end if;
         end if;
      end handle_case;

   begin
      prefix := null_sexpr_string;
      other := source;
      i := 1;
      if i /= n + 1 then
         case element (source, i) is
            when 'b' | 'o' | 'd' | 'x' =>
               handle_case (['e', 'i']);

            when 'e' | 'i'             =>
               handle_case (['b', 'o', 'd', 'x']);

            when others                =>
               null;
         end case;
      end if;
   end split_at_numeral_prefix;

   function is_numeral_hash_token
     (source : in sexpr_string) return boolean
   is
      prefix : sexpr_string;
      other  : sexpr_string;
   begin
      split_at_numeral_prefix (source, prefix, other);
      return (length (prefix) /= 0);
   end is_numeral_hash_token;

   function is_datum_label (source : in sexpr_string) return boolean is
      n : constant natural := length (source);
      type char_array is array (1 .. n) of sexpr_character;
      s : constant char_array := char_array (to_sexpr_fixstr (source));
   begin
      return
        (2 <= n
         and then (s (n) = '#'
                   and (for all elem of s (1 .. n - 1) =>
                          is_ascii_digit (elem))));
   end is_datum_label;

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
      res     : sexpr;
      s       : constant sexpr_string := collect_identifier (ctx);
      s_lower : constant sexpr_string := to_lower (s);
   begin
      if s_lower = short_form or s_lower = long_form then
         res := make_boolean (value);
      else
         raise parse_error with unrecognized_hash_token_message (s);
      end if;
      return res;
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
      bv_count  : natural := 0;
      cur       : sexpr;
      res       : sexpr;
   begin
      if is_eof (ctx) or else peek_char (ctx) /= '(' then
         raise parse_error with "expected '(' after #u8";
      else
         adv_char (ctx); -- skip '('
         temp_list := parse_list_items (ctx);
         bv_count := length (temp_list);

         declare
            bytes : byte_array (1 .. bv_count);
            idx   : positive := 1;
            val   : bignum_integer;
         begin
            cur := temp_list;
            while is_pair (cur) loop
               val := get_integer (car (cur));
               if val < 0 or 255 < val then
                  raise parse_error
                    with "bytevector element out of range: " & val'img;
               end if;
               bytes (idx) := interfaces.unsigned_8 (to_integer (val));
               idx := idx + 1;
               cur := cdr (cur);
            end loop;
            res := make_bytevector (bytes);
         end;
      end if;
      return res;
   end collect_bytevector;

   function make_homogeneous_vector_sexpr
     (ctx : in out parse_context) return sexpr
   is
      res     : sexpr;
      s       : constant sexpr_string := collect_identifier (ctx);
      s_lower : constant sexpr_string := to_lower (s);
   begin
      if s_lower = "u8" then
         res := collect_bytevector (ctx);
      else
         raise parse_error with unrecognized_hash_token_message (s);
      end if;
      return res;
   end make_homogeneous_vector_sexpr;

   function make_digits_sexpr (ctx : in out parse_context) return sexpr
   is
   begin
      null; ----????????????????????????????????????????????????????????????????????????????????????????????????????
      return make_null;
   end make_digits_sexpr;

   function parse_hash_prefix (ctx : in out parse_context) return sexpr
   is
      res      : sexpr;
      token    : sexpr_string;
      toklower : sexpr_string;
      prefix   : sexpr_string;
   begin
      adv_char (ctx); -- skip '#'
      if is_eof (ctx) then
         raise parse_error with "unexpected eof after '#'";
      else
         case peek_char (ctx) is
            when '\'        =>
               res := make_character_from_hash_token (ctx);

            when '('        =>
               res := make_vector_sexpr (ctx);

            when 't' | 'T'  =>
               res := make_boolean_sexpr (ctx, "t", "true", true);

            when 'f' | 'F'  =>
               res := make_boolean_sexpr (ctx, "f", "false", false);

            when 'u' | 'U'  =>
               res := make_homogeneous_vector_sexpr (ctx);

            when '0' .. '9' =>
               res := make_digits_sexpr (ctx);

            when '.'        =>
               null;            -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
               raise parse_error with "not yet implemented";

            when others     =>
               token :=
                 collect_hash_token_start
                   (ctx); -------------------------------- FIXME: DO NOT DO IT THIS WAY
               toklower :=
                 token;  -- FIXME: POSSIBLY SUPPORT CASE-FOLDING.
               --put_line
               --  (to_sexpr_fixstr
               --    (token)); -------------------------------------------------- FIXME FIXME FIXME FIXME FIXME
               if length (token) = 0 then
                  -- FIXME: GATHER SOME CONTEXT.
                  raise parse_error with "unrecognized hash token '#'";
               elsif is_datum_label (toklower) then
                  null; -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
               elsif is_numeral_hash_token (toklower) then
                  null; -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
               end if;
         end case;
      end if;
      return res;
   end parse_hash_prefix;

   --         when others                            =>
   --            elsif is_ascii_digit (c) then
   --               declare
   --                  lbl_num : natural := 0;
   --               begin
   --                  while not is_eof (ctx)
   --                        and then is_ascii_digit (peek_char (ctx))
   --                  loop
   --                     lbl_num :=
   --                       lbl_num
   --                         * 10
   --                       + (sexpr_character'pos (peek_char (ctx))
   --                          - sexpr_character'pos ('0'));
   --                     adv_char (ctx);
   --                  end loop;
   --                  if not is_eof (ctx) and then peek_char (ctx) = '='
   --                  then
   --                     adv_char (ctx);
   --                     res := parse_datum (ctx, lbl);
   --                     if lbl.count < lbl.entries'last then
   --                        lbl.count := lbl.count + 1;
   --                        lbl.entries (lbl.count).id := lbl_num;
   --                        lbl.entries (lbl.count).val := res;
   --                     end if;
   --                  elsif not is_eof (ctx) and then peek_char (ctx) = '#'
   --                  then
   --                     adv_char (ctx);
   --                     declare
   --                        found : boolean := false;
   --                     begin
   --                        for idx in 1 .. lbl.count loop
   --                           if lbl.entries (idx).id = lbl_num then
   --                              res := lbl.entries (idx).val;
   --                              found := true;
   --                           end if;
   --                        end loop;
   --                        if not found then
   --                           raise parse_error
   --                           with
   --                             "unknown datum label #"
   --                             & trim_left (lbl_num'img)
   --                             & "#";
   --                        end if;
   --                     end;
   --                  else
   --                     raise parse_error
   --                     with "malformed datum label syntax";
   --                  end if;
   --               end;
   --            else
   --               unrecognized_hash_token (c'img);
   --            end if;
   --      end case;
   --      return res;

   --   function parse_hash_prefix
   --     (ctx : in out parse_context; lbl : in out label_context)
   --     return sexpr
   --   is
   --      res : sexpr;
   --      c   : sexpr_character;
   --   begin
   --      adv_char (ctx); -- skip '#'
   --      if is_eof (ctx) then
   --         raise parse_error with "unexpected eof after '#'";
   --      end if;
   --      c := peek_char (ctx);
   --      case c is
   --         when 't' | 'T'                         =>
   --            adv_char (ctx);
   --            skip_rue (ctx, c);  -- Handle #true
   --            res := make_boolean (true);
   --
   --         when 'f' | 'F'                         =>
   --            adv_char (ctx);
   --            skip_alse (ctx, c); -- Handle #false
   --            res := make_boolean (false);
   --
   --         when '\'                               =>
   --            res := parse_character_literal (ctx);
   --
   --         when '('                               =>
   --            res := parse_vector_literal (ctx, lbl);
   --
   --         when 'b' | 'B'                         =>
   --            adv_char (ctx);
   --            declare
   --               tok : sexpr_string := null_sexpr_string;
   --            begin
   --               while not is_eof (ctx)
   --                     and then not is_delimiter (peek_char (ctx))
   --               loop
   --                  tok := @ & peek_char (ctx);
   --                  adv_char (ctx);
   --               end loop;
   --               res := parse_number_or_symbol (tok, 2);
   --            end;
   --
   --         when 'o' | 'O'                         =>
   --            adv_char (ctx);
   --            declare
   --               tok : sexpr_string := null_sexpr_string;
   --            begin
   --               while not is_eof (ctx)
   --                     and then not is_delimiter (peek_char (ctx))
   --               loop
   --                  append (tok, peek_char (ctx));
   --                  adv_char (ctx);
   --               end loop;
   --               res := parse_number_or_symbol (tok, 8);
   --            end;
   --
   --         when 'x' | 'X'                         =>
   --            adv_char (ctx);
   --            declare
   --               tok : sexpr_string := null_sexpr_string;
   --            begin
   --               while not is_eof (ctx)
   --                     and then not is_delimiter (peek_char (ctx))
   --               loop
   --                  append (tok, peek_char (ctx));
   --                  adv_char (ctx);
   --               end loop;
   --               res := parse_number_or_symbol (tok, 16);
   --            end;
   --
   --         when 'd' | 'D' | 'e' | 'E' | 'i' | 'I' =>
   --            adv_char (ctx);
   --            declare
   --               tok : sexpr_string := null_sexpr_string;
   --            begin
   --               while not is_eof (ctx)
   --                     and then not is_delimiter (peek_char (ctx))
   --               loop
   --                  append (tok, peek_char (ctx));
   --                  adv_char (ctx);
   --               end loop;
   --               res := parse_number_or_symbol (tok, 10);
   --            end;
   --
   --         when others                            =>
   --            if match_two (c, ctx, 'u', '8') then
   --               res := parse_bytevector_literal (ctx, lbl);
   --            elsif is_ascii_digit (c) then
   --               declare
   --                  lbl_num : natural := 0;
   --               begin
   --                  while not is_eof (ctx)
   --                        and then is_ascii_digit (peek_char (ctx))
   --                  loop
   --                     lbl_num :=
   --                       lbl_num
   --                         * 10
   --                       + (sexpr_character'pos (peek_char (ctx))
   --                          - sexpr_character'pos ('0'));
   --                     adv_char (ctx);
   --                  end loop;
   --                  if not is_eof (ctx) and then peek_char (ctx) = '='
   --                  then
   --                     adv_char (ctx);
   --                     res := parse_datum (ctx, lbl);
   --                     if lbl.count < lbl.entries'last then
   --                        lbl.count := lbl.count + 1;
   --                        lbl.entries (lbl.count).id := lbl_num;
   --                        lbl.entries (lbl.count).val := res;
   --                     end if;
   --                  elsif not is_eof (ctx) and then peek_char (ctx) = '#'
   --                  then
   --                     adv_char (ctx);
   --                     declare
   --                        found : boolean := false;
   --                     begin
   --                        for idx in 1 .. lbl.count loop
   --                           if lbl.entries (idx).id = lbl_num then
   --                              res := lbl.entries (idx).val;
   --                              found := true;
   --                           end if;
   --                        end loop;
   --                        if not found then
   --                           raise parse_error
   --                           with
   --                             "unknown datum label #"
   --                             & trim_left (lbl_num'img)
   --                             & "#";
   --                        end if;
   --                     end;
   --                  else
   --                     raise parse_error
   --                     with "malformed datum label syntax";
   --                  end if;
   --               end;
   --            else
   --               unrecognized_hash_token (c'img);
   --            end if;
   --      end case;
   --      return res;
   --   end parse_hash_prefix;

   function parse_datum (ctx : in out parse_context) return sexpr is
      res : sexpr := make_null;
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
            res := parse_list_items (ctx);
         elsif c = sexpr_character'('"') then
            res := parse_string_literal (ctx);
         elsif c = sexpr_character'('|') then
            res := parse_vertical_symbol (ctx);
         elsif c = sexpr_character'('#') then
            res := parse_hash_prefix (ctx);
         elsif c = sexpr_character'(''') then
            adv_char (ctx);
            declare
               sub : sexpr := parse_datum (ctx);
            begin
               res :=
                 cons (make_symbol ("quote"), cons (sub, make_null));
            end;
         elsif c = sexpr_character'('`') then
            adv_char (ctx);
            declare
               sub : sexpr := parse_datum (ctx);
            begin
               res :=
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
                  res :=
                    cons
                      (make_symbol ("unquote-splicing"),
                       cons (sub, make_null));
               end;
            else
               declare
                  sub : sexpr := parse_datum (ctx);
               begin
                  res :=
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
               res := parse_number_or_symbol (tok);
            end;
         end if;
      end;
      return res;
   end parse_datum;

   ---------------------------------------------------------------------
   --
   -- Input and deserialization.
   --

   function read_from_string (source : in sexpr_string) return sexpr is
      ctx : parse_context;
      res : sexpr;
   begin
      ctx.src := source;
      ctx.pos := 1;
      ctx.len := length (ctx.src);
      res := parse_datum (ctx);
      return res;
   end read_from_string;

   function read_from_string (source : in sexpr_fixstr) return sexpr is
   begin
      return read_from_string (to_sexpr_string (source));
   end read_from_string;

   function read_all_from_string
     (source : in sexpr_string) return sexpr_array
   is
      ctx       : parse_context;
      temp_list : sexpr := make_null;
      cnt       : natural := 0;
   begin
      ctx.src := source;
      ctx.pos := 1;
      ctx.len := length (ctx.src);

      skip_whitespace_and_comments (ctx);
      while not is_eof (ctx) loop
         declare
            d : sexpr := parse_datum (ctx);
         begin
            temp_list := cons (d, temp_list);
            cnt := cnt + 1;
         end;
         skip_whitespace_and_comments (ctx);
      end loop;

      declare
         arr : sexpr_array (1 .. cnt);
         cur : sexpr := temp_list;
      begin
         for i in reverse 1 .. cnt loop
            arr (i) := car (cur);
            cur := cdr (cur);
         end loop;
         return arr;
      end;
   end read_all_from_string;

   function read_file_content
     (file_path : in string) return sexpr_string
   is
      file : file_type;
      buf  : sexpr_string := null_sexpr_string;
   begin
      begin
         open (file, in_file, file_path);
      exception
         when others =>
            raise io_error
              with "cannot open file for reading: " & file_path;
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

   function read_from_file (file_path : in string) return sexpr is
      content : sexpr_string := read_file_content (file_path);
      res     : sexpr := read_from_string (content);
   begin
      return res;
   end read_from_file;

   function read_all_from_file
     (file_path : in string) return sexpr_array
   is
      content : sexpr_string := read_file_content (file_path);
   begin
      return read_all_from_string (content);
   end read_all_from_file;

   ---------------------------------------------------------------------
   --
   -- Output and serialization
   --

   procedure serialize_datum
     (e : in sexpr; display : in boolean; buf : in out sexpr_string);

   procedure serialize_string
     (str     : in sexpr_string;
      display : in boolean;
      buf     : in out sexpr_string) is
   begin
      if display then
         append (buf, str);
      else
         append (buf, '"');
         for i in 1 .. length (str) loop
            declare
               c : sexpr_character := element (str, i);
            begin
               case c is
                  when sexpr_character'('"') =>
                     append (buf, "\""");

                  when sexpr_character'('\') =>
                     append (buf, "\\");

                  when sexpr_newline         =>
                     append (buf, "\n");

                  when sexpr_tab             =>
                     append (buf, "\t");

                  when sexpr_return          =>
                     append (buf, "\r");

                  when others                =>
                     append (buf, c);
               end case;
            end;
         end loop;
         buf := @ & sexpr_character'('"');
      end if;
   end serialize_string;

   procedure serialize_character
     (ch      : in sexpr_character;
      display : in boolean;
      buf     : in out sexpr_string)
   is
      code : natural := sexpr_character'pos (ch);
   begin
      if display then
         if code <= 255 then
            append (buf, sexpr_character'val (code));
         else
            append (buf, '?');
         end if;
      else
         append (buf, "#\");
         case code is
            when 32        =>
               append (buf, "space");

            when 10        =>
               append (buf, "newline");

            when 9         =>
               append (buf, "tab");

            when 13        =>
               append (buf, "return");

            when 7         =>
               append (buf, "alarm");

            when 8         =>
               append (buf, "backspace");

            when 27        =>
               append (buf, "escape");

            when 0         =>
               append (buf, "null");

            when 127       =>
               append (buf, "delete");

            when 33 .. 126 =>
               append (buf, sexpr_character'val (code));

            when others    =>
               append (buf, "x");
               declare
                  hex_str : sexpr_string := to_sexpr_string (code'img);
               begin
                  buf :=
                    @
                    & unbounded_slice (hex_str, 2, length (hex_str))
                    & sexpr_fixstr'(";");
               end;
         end case;
      end if;
   end serialize_character;

   procedure serialize_list
     (e : in sexpr; display : in boolean; buf : in out sexpr_string)
   is
      cur   : sexpr := e;
      first : boolean := true;
   begin
      append (buf, '(');
      while is_pair (cur) loop
         if not first then
            append (buf, ' ');
         end if;
         first := false;
         serialize_datum (car (cur), display, buf);
         cur := cdr (cur);
      end loop;

      if not is_null (cur) then
         append (buf, " . ");
         serialize_datum (cur, display, buf);
      end if;
      append (buf, ')');
   end serialize_list;

   procedure serialize_vector
     (e : in sexpr; display : in boolean; buf : in out sexpr_string)
   is
      len : natural := vector_length (e);
   begin
      append (buf, "#(");
      for idx in 1 .. len loop
         if idx > 1 then
            append (buf, ' ');
         end if;
         serialize_datum (vector_ref (e, idx), display, buf);
      end loop;
      append (buf, ')');
   end serialize_vector;

   procedure serialize_bytevector
     (e : in sexpr; buf : in out sexpr_string)
   is
      len : natural := bytevector_length (e);
   begin
      append (buf, "#u8(");
      for idx in 1 .. len loop
         if idx > 1 then
            append (buf, ' ');
         end if;
         declare
            b_val : interfaces.unsigned_8 := bytevector_ref (e, idx);
            s_val : sexpr_string := to_sexpr_string (b_val'img);
         begin
            buf := @ & unbounded_slice (s_val, 2, length (s_val));
         end;
      end loop;
      buf := @ & sexpr_character'(')');
   end serialize_bytevector;

   procedure serialize_datum
     (e : in sexpr; display : in boolean; buf : in out sexpr_string) is
   begin
      if is_null (e) then
         append (buf, "()");
      else
         case e.ptr.kind is
            when kind_null       =>
               append (buf, "()");

            when kind_boolean    =>
               if e.ptr.boolean_val then
                  append (buf, "#t");
               else
                  append (buf, "#f");
               end if;

            when kind_integer    =>
               buf :=
                 @
                 & to_sexpr_string
                     (trim_left (to_string (e.ptr.integer_val)));

            when kind_inexact    =>
               buf :=
                 @
                 & to_sexpr_string (trim_left (e.ptr.inexact_val'img));

            when kind_rational   =>
               buf :=
                 @
                 & to_sexpr_string
                     (trim_left
                        (to_string (numerator (e.ptr.rational_val))))
                 & '/'
                 & to_sexpr_string
                     (trim_left
                        (to_string (denominator (e.ptr.rational_val))));

            when kind_character  =>
               serialize_character (e.ptr.character_val, display, buf);

            when kind_string     =>
               serialize_string (e.ptr.string_val, display, buf);

            when kind_symbol     =>
               append (buf, e.ptr.symbol_val);

            when kind_pair       =>
               serialize_list (e, display, buf);

            when kind_vector     =>
               serialize_vector (e, display, buf);

            when kind_bytevector =>
               serialize_bytevector (e, buf);
         end case;
      end if;
   end serialize_datum;

   function write_to_string (e : in sexpr) return sexpr_string is
      buf : sexpr_string := null_sexpr_string;
   begin
      serialize_datum (e, false, buf);
      return buf;
   end write_to_string;

   function write_simple_to_string (e : in sexpr) return sexpr_string is
      res : sexpr_string := write_to_string (e);
   begin
      return res;
   end write_simple_to_string;

   function display_to_string (e : in sexpr) return sexpr_string is
      buf : sexpr_string := null_sexpr_string;
   begin
      serialize_datum (e, true, buf);
      return buf;
   end display_to_string;

   procedure write_to_file (e : in sexpr; file_path : in string) is
      file : file_type;
   begin
      begin
         create (file, out_file, file_path, form => "WCEM=8");
      exception
         when others =>
            raise io_error
              with "cannot create file for writing: " & file_path;
      end;
      put_line (file, to_sexpr_fixstr (write_to_string (e)));
      close (file);
   end write_to_file;

   procedure display_to_file (e : in sexpr; file_path : in string) is
      file : file_type;
   begin
      begin
         create (file, out_file, file_path, form => "WCEM=8");
      exception
         when others =>
            raise io_error
              with "cannot create file for writing: " & file_path;
      end;
      put_line (file, to_sexpr_fixstr (display_to_string (e)));
      close (file);
   end display_to_file;

   ---------------------------------------------------------------------

begin
   initialize_character_name_lookup;
end sexpressions;

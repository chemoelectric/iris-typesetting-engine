--  r7rs_sexpr.adb --- R7RS Scheme S-Expression I/O Implementation
--
--  SPDX-License-Identifier: MIT

with interfaces;
with ada.characters.handling;
with ada.io_exceptions;
with ada.strings.fixed;
with ada.text_io;
with ada.unchecked_deallocation;

package body r7rs_sexpr is

   use interfaces;
   use ada.characters.handling;
   use ada.strings.fixed;

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
              and then obj.ptr.vec_val /= null
            then
               free_vec (obj.ptr.vec_val);
            elsif obj.ptr.kind = kind_bytevector
              and then obj.ptr.bytes_val /= null
            then
               free_bytes (obj.ptr.bytes_val);
            end if;
            free_node (obj.ptr);
         end if;
         obj.ptr := null;
      end if;
   end finalize;

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
      res.ptr.bool_val := val;
      return res;
   end make_boolean;

   function make_integer (val : in long_long_integer) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_integer);
      res.ptr.int_val := val;
      return res;
   end make_integer;

   function make_real (val : in long_float) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_real);
      res.ptr.real_val := val;
      return res;
   end make_real;

   function make_rational
     (num : in long_long_integer; den : in long_long_integer)
      return sexpr
   is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_rational);
      res.ptr.num_val := num;
      res.ptr.den_val := den;
      return res;
   end make_rational;

   function make_character (ch : in wide_wide_character) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_character);
      res.ptr.char_val := ch;
      return res;
   end make_character;

   function make_character (ch : in character) return sexpr is
      res : sexpr;
   begin
      res :=
        make_character (wide_wide_character'val (character'pos (ch)));
      return res;
   end make_character;

   function make_string (str : in unbounded_string) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_string);
      res.ptr.str_val := str;
      return res;
   end make_string;

   function make_string (str : in string) return sexpr is
      res : sexpr;
   begin
      res := make_string (to_unbounded_string (str));
      return res;
   end make_string;

   function make_symbol (sym : in unbounded_string) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_symbol);
      res.ptr.sym_val := sym;
      return res;
   end make_symbol;

   function make_symbol (sym : in string) return sexpr is
      res : sexpr;
   begin
      res := make_symbol (to_unbounded_string (sym));
      return res;
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
      res.ptr.vec_val := new sexpr_array (1 .. items'length);
      for idx in items'range loop
         res.ptr.vec_val (idx - items'first + 1) := items (idx);
      end loop;
      return res;
   end make_vector;

   function make_bytevector (bytes : in byte_array) return sexpr is
      res : sexpr;
   begin
      res.ptr := new node_record (kind_bytevector);
      res.ptr.bytes_val := new byte_array (1 .. bytes'length);
      for idx in bytes'range loop
         res.ptr.bytes_val (idx - bytes'first + 1) := bytes (idx);
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

   function is_real (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_real);
      return res;
   end is_real;

   function is_rational (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      res := (e.ptr /= null and then e.ptr.kind = kind_rational);
      return res;
   end is_rational;

   function is_number (e : in sexpr) return boolean is
      res : boolean := false;
   begin
      if e.ptr /= null then
         case e.ptr.kind is
            when kind_integer | kind_real | kind_rational =>
               res := true;

            when others                                   =>
               res := false;
         end case;
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
         res := e.ptr.bool_val;
      else
         raise type_error with "expected boolean s-expression";
      end if;
      return res;
   end get_boolean;

   function get_integer (e : in sexpr) return long_long_integer is
      res : long_long_integer := 0;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_integer then
         res := e.ptr.int_val;
      else
         raise type_error with "expected integer s-expression";
      end if;
      return res;
   end get_integer;

   function get_real (e : in sexpr) return long_float is
      res : long_float := 0.0;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_real then
         res := e.ptr.real_val;
      elsif e.ptr /= null and then e.ptr.kind = kind_integer then
         res := long_float (e.ptr.int_val);
      else
         raise type_error with "expected real s-expression";
      end if;
      return res;
   end get_real;

   function get_numerator (e : in sexpr) return long_long_integer is
      res : long_long_integer := 0;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_rational then
         res := e.ptr.num_val;
      else
         raise type_error with "expected rational s-expression";
      end if;
      return res;
   end get_numerator;

   function get_denominator (e : in sexpr) return long_long_integer is
      res : long_long_integer := 1;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_rational then
         res := e.ptr.den_val;
      else
         raise type_error with "expected rational s-expression";
      end if;
      return res;
   end get_denominator;

   function get_character (e : in sexpr) return wide_wide_character is
      res : wide_wide_character := ' ';
   begin
      if e.ptr /= null and then e.ptr.kind = kind_character then
         res := e.ptr.char_val;
      else
         raise type_error with "expected character s-expression";
      end if;
      return res;
   end get_character;

   function get_string (e : in sexpr) return unbounded_string is
      res : unbounded_string := null_unbounded_string;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_string then
         res := e.ptr.str_val;
      else
         raise type_error with "expected string s-expression";
      end if;
      return res;
   end get_string;

   function get_string_str (e : in sexpr) return string is
      res : string := to_string (get_string (e));
   begin
      return res;
   end get_string_str;

   function get_symbol (e : in sexpr) return unbounded_string is
      res : unbounded_string := null_unbounded_string;
   begin
      if e.ptr /= null and then e.ptr.kind = kind_symbol then
         res := e.ptr.sym_val;
      else
         raise type_error with "expected symbol s-expression";
      end if;
      return res;
   end get_symbol;

   function get_symbol_str (e : in sexpr) return string is
      res : string := to_string (get_symbol (e));
   begin
      return res;
   end get_symbol_str;

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
        and then e.ptr.vec_val /= null
      then
         res := e.ptr.vec_val'length;
      end if;
      return res;
   end vector_length;

   function vector_ref (e : in sexpr; idx : in positive) return sexpr is
      res : sexpr;
   begin
      if e.ptr /= null
        and then e.ptr.kind = kind_vector
        and then e.ptr.vec_val /= null
        and then idx in e.ptr.vec_val'range
      then
         res := e.ptr.vec_val (idx);
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
        and then e.ptr.bytes_val /= null
      then
         res := e.ptr.bytes_val'length;
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
        and then e.ptr.bytes_val /= null
        and then idx in e.ptr.bytes_val'range
      then
         res := e.ptr.bytes_val (idx);
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
      if is_null (a) and then is_null (b) then
         res := true;
      elsif ka /= kb then
         res := false;
      else
         case ka is
            when kind_null       =>
               res := true;

            when kind_boolean    =>
               res := (a.ptr.bool_val = b.ptr.bool_val);

            when kind_integer    =>
               res := (a.ptr.int_val = b.ptr.int_val);

            when kind_real       =>
               res := (a.ptr.real_val = b.ptr.real_val);

            when kind_rational   =>
               res :=
                 (a.ptr.num_val = b.ptr.num_val
                  and then a.ptr.den_val = b.ptr.den_val);

            when kind_character  =>
               res := (a.ptr.char_val = b.ptr.char_val);

            when kind_string     =>
               res := (a.ptr.str_val = b.ptr.str_val);

            when kind_symbol     =>
               res := (a.ptr.sym_val = b.ptr.sym_val);

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
      res : boolean := equal (a, b);
   begin
      return res;
   end eqv;

   function assoc (key : in sexpr; alist : in sexpr) return sexpr is
      cur   : sexpr := alist;
      res   : sexpr := make_null;
      found : boolean := false;
   begin
      while is_pair (cur) and not found loop
         declare
            elem : sexpr := car (cur);
         begin
            if is_pair (elem) and then equal (car (elem), key) then
               res := elem;
               found := true;
            end if;
         end;
         cur := cdr (cur);
      end loop;
      return res;
   end assoc;

   function assoc (key_sym : in string; alist : in sexpr) return sexpr
   is
      k   : sexpr := make_symbol (key_sym);
      res : sexpr := assoc (k, alist);
   begin
      return res;
   end assoc;

   function assoc
     (key_sym : in unbounded_string; alist : in sexpr) return sexpr
   is
      k   : sexpr := make_symbol (key_sym);
      res : sexpr := assoc (k, alist);
   begin
      return res;
   end assoc;

   function assq (key_sym : in string; alist : in sexpr) return sexpr is
      res : sexpr := assoc (key_sym, alist);
   begin
      return res;
   end assq;

   function acons
     (key : in sexpr; val : in sexpr; alist : in sexpr) return sexpr
   is
      p   : sexpr := cons (key, val);
      res : sexpr := cons (p, alist);
   begin
      return res;
   end acons;

   ---------------------------------------------------------------------
   -- Lexer & Parser Implementation
   ---------------------------------------------------------------------

   type parse_context is record
      src       : unbounded_string;
      pos       : positive := 1;
      len       : natural := 0;
      fold_case : boolean := false;
   end record;

   type label_entry is record
      id  : natural;
      val : sexpr;
   end record;

   type label_table_array is array (1 .. 128) of label_entry;

   type label_context is record
      count   : natural := 0;
      entries : label_table_array;
   end record;

   function is_eof (ctx : in parse_context) return boolean is
      res : boolean := (ctx.pos > ctx.len);
   begin
      return res;
   end is_eof;

   function peek_char (ctx : in parse_context) return character is
      res : character := ascii.nul;
   begin
      if ctx.pos <= ctx.len then
         res := element (ctx.src, ctx.pos);
      end if;
      return res;
   end peek_char;

   function peek_next_char (ctx : in parse_context) return character is
      res : character := ascii.nul;
   begin
      if ctx.pos + 1 <= ctx.len then
         res := element (ctx.src, ctx.pos + 1);
      end if;
      return res;
   end peek_next_char;

   procedure adv_char (ctx : in out parse_context) is
   begin
      if ctx.pos <= ctx.len then
         ctx.pos := ctx.pos + 1;
      end if;
   end adv_char;

   function is_delimiter (c : in character) return boolean is
      res : boolean := false;
   begin
      case c is
         when ' '
            | ascii.ht
            | ascii.lf
            | ascii.cr
            | ascii.ff
            | '('
            | ')'
            | '"'
            | ';'
            | '|'
            | '['
            | ']'    =>
            res := true;

         when others =>
            res := false;
      end case;
      return res;
   end is_delimiter;

   function parse_datum
     (ctx : in out parse_context; lbl : in out label_context)
      return sexpr;

   procedure skip_line_comment (ctx : in out parse_context) is
      ch : character := peek_char (ctx);
   begin
      while not is_eof (ctx)
        and then ch /= ascii.lf
        and then ch /= ascii.cr
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
         if peek_char (ctx) = '#' and then peek_next_char (ctx) = '|'
         then
            depth := depth + 1;
            adv_char (ctx);
            adv_char (ctx);
         elsif peek_char (ctx) = '|' and then peek_next_char (ctx) = '#'
         then
            depth := depth - 1;
            adv_char (ctx);
            adv_char (ctx);
         else
            adv_char (ctx);
         end if;
      end loop;
   end skip_nested_comment;

   procedure skip_whitespace_and_comments
     (ctx : in out parse_context; lbl : in out label_context)
   is
      changed : boolean := true;
   begin
      while not is_eof (ctx) and changed loop
         changed := false;
         declare
            c : character := peek_char (ctx);
         begin
            if c = ' '
              or else c = ascii.ht
              or else c = ascii.lf
              or else c = ascii.cr
              or else c = ascii.ff
            then
               adv_char (ctx);
               changed := true;
            elsif c = ';' then
               skip_line_comment (ctx);
               changed := true;
            elsif c = '#' and then peek_next_char (ctx) = '|' then
               skip_nested_comment (ctx);
               changed := true;
            elsif c = '#' and then peek_next_char (ctx) = ';' then
               adv_char (ctx);
               adv_char (ctx);
               declare
                  discarded : sexpr;
               begin
                  discarded := parse_datum (ctx, lbl);
               end;
               changed := true;
            elsif c = '#' and then peek_next_char (ctx) = '!' then
               adv_char (ctx);
               adv_char (ctx);
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  adv_char (ctx);
               end loop;
               changed := true;
            end if;
         end;
      end loop;
   end skip_whitespace_and_comments;

   function is_hex_digit (c : in character) return boolean is
      res : boolean := false;
   begin
      if c in '0' .. '9'
        or else c in 'a' .. 'f'
        or else c in 'A' .. 'F'
      then
         res := true;
      end if;
      return res;
   end is_hex_digit;

   function parse_hex_digit (c : in character) return natural is
      res : natural := 0;
   begin
      if c in '0' .. '9' then
         res := character'pos (c) - character'pos ('0');
      elsif c in 'a' .. 'f' then
         res := character'pos (c) - character'pos ('a') + 10;
      elsif c in 'A' .. 'F' then
         res := character'pos (c) - character'pos ('A') + 10;
      else
         raise parse_error with "invalid hex digit: " & c;
      end if;
      return res;
   end parse_hex_digit;

   function parse_string_literal
     (ctx : in out parse_context) return sexpr
   is
      buf : unbounded_string := null_unbounded_string;
   begin
      adv_char (ctx); -- skip opening '"'
      while not is_eof (ctx) and then peek_char (ctx) /= '"' loop
         declare
            c : character := peek_char (ctx);
         begin
            if c = '\' then
               adv_char (ctx);
               if is_eof (ctx) then
                  raise parse_error with "unterminated string escape";
               end if;
               declare
                  esc : character := peek_char (ctx);
               begin
                  case esc is
                     when 'a'                                  =>
                        append (buf, ascii.bel);
                        adv_char (ctx);

                     when 'b'                                  =>
                        append (buf, ascii.bs);
                        adv_char (ctx);

                     when 't'                                  =>
                        append (buf, ascii.ht);
                        adv_char (ctx);

                     when 'n'                                  =>
                        append (buf, ascii.lf);
                        adv_char (ctx);

                     when 'r'                                  =>
                        append (buf, ascii.cr);
                        adv_char (ctx);

                     when '"'                                  =>
                        append (buf, '"');
                        adv_char (ctx);

                     when '\'                                  =>
                        append (buf, '\');
                        adv_char (ctx);

                     when '|'                                  =>
                        append (buf, '|');
                        adv_char (ctx);

                     when 'x'                                  =>
                        adv_char (ctx);
                        declare
                           hex_val : natural := 0;
                        begin
                           while not is_eof (ctx)
                             and then peek_char (ctx) /= ';'
                             and then not is_delimiter (peek_char (ctx))
                           loop
                              hex_val :=
                                hex_val
                                * 16
                                + parse_hex_digit (peek_char (ctx));
                              adv_char (ctx);
                           end loop;
                           if not is_eof (ctx)
                             and then peek_char (ctx) = ';'
                           then
                              adv_char (ctx);
                           end if;
                           if hex_val <= 255 then
                              append (buf, character'val (hex_val));
                           else
                              append (buf, '?');
                           end if;
                        end;

                     when ' ' | ascii.ht | ascii.lf | ascii.cr =>
                        while not is_eof (ctx)
                          and then (peek_char (ctx) = ' '
                                    or else peek_char (ctx) = ascii.ht
                                    or else peek_char (ctx) = ascii.lf
                                    or else peek_char (ctx) = ascii.cr)
                        loop
                           adv_char (ctx);
                        end loop;

                     when others                               =>
                        append (buf, esc);
                        adv_char (ctx);
                  end case;
               end;
            else
               append (buf, c);
               adv_char (ctx);
            end if;
         end;
      end loop;
      if is_eof (ctx) then
         raise parse_error with "unterminated string literal";
      end if;
      adv_char (ctx); -- skip closing '"'
      return make_string (buf);
   end parse_string_literal;

   function parse_vertical_symbol
     (ctx : in out parse_context) return sexpr
   is
      buf : unbounded_string := null_unbounded_string;
   begin
      adv_char (ctx); -- skip opening '|'
      while not is_eof (ctx) and then peek_char (ctx) /= '|' loop
         declare
            c : character := peek_char (ctx);
         begin
            if c = '\' then
               adv_char (ctx);
               if is_eof (ctx) then
                  raise parse_error with "unterminated symbol escape";
               end if;
               declare
                  esc : character := peek_char (ctx);
               begin
                  if esc = '|' or else esc = '\' then
                     append (buf, esc);
                     adv_char (ctx);
                  elsif esc = 'x' then
                     adv_char (ctx);
                     declare
                        hex_val : natural := 0;
                     begin
                        while not is_eof (ctx)
                          and then peek_char (ctx) /= ';'
                          and then not is_delimiter (peek_char (ctx))
                        loop
                           hex_val :=
                             hex_val
                             * 16
                             + parse_hex_digit (peek_char (ctx));
                           adv_char (ctx);
                        end loop;
                        if not is_eof (ctx)
                          and then peek_char (ctx) = ';'
                        then
                           adv_char (ctx);
                        end if;
                        if hex_val <= 255 then
                           append (buf, character'val (hex_val));
                        else
                           append (buf, '?');
                        end if;
                     end;
                  else
                     append (buf, esc);
                     adv_char (ctx);
                  end if;
               end;
            else
               append (buf, c);
               adv_char (ctx);
            end if;
         end;
      end loop;
      if is_eof (ctx) then
         raise parse_error with "unterminated vertical bar symbol";
      end if;
      adv_char (ctx); -- skip closing '|'
      return make_symbol (buf);
   end parse_vertical_symbol;

   function parse_named_char
     (name : in string) return wide_wide_character
   is
      res : wide_wide_character := ' ';
      low : string := to_lower (name);
   begin
      if low = "space" then
         res := ' ';
      elsif low = "newline" then
         res := wide_wide_character'val (10);
      elsif low = "tab" then
         res := wide_wide_character'val (9);
      elsif low = "return" then
         res := wide_wide_character'val (13);
      elsif low = "alarm" then
         res := wide_wide_character'val (7);
      elsif low = "backspace" then
         res := wide_wide_character'val (8);
      elsif low = "escape" then
         res := wide_wide_character'val (27);
      elsif low = "null" then
         res := wide_wide_character'val (0);
      elsif low = "delete" then
         res := wide_wide_character'val (127);
      elsif name'length = 1 then
         res :=
           wide_wide_character'val (character'pos (name (name'first)));
      else
         raise parse_error with "unknown character name: " & name;
      end if;
      return res;
   end parse_named_char;

   function parse_character_literal
     (ctx : in out parse_context) return sexpr
   is
      res : sexpr;
   begin
      adv_char (ctx); -- skip '\'
      if is_eof (ctx) then
         raise parse_error with "unexpected eof after #\";
      end if;

      if peek_char (ctx) = 'x'
        and then not is_delimiter (peek_next_char (ctx))
        and then is_hex_digit (peek_next_char (ctx))
      then
         adv_char (ctx); -- skip 'x'
         declare
            hex_val : natural := 0;
         begin
            while not is_eof (ctx)
              and then peek_char (ctx) /= ';'
              and then not is_delimiter (peek_char (ctx))
            loop
               hex_val :=
                 hex_val * 16 + parse_hex_digit (peek_char (ctx));
               adv_char (ctx);
            end loop;
            if not is_eof (ctx) and then peek_char (ctx) = ';' then
               adv_char (ctx);
            end if;
            res := make_character (wide_wide_character'val (hex_val));
         end;
      elsif is_delimiter (peek_char (ctx)) then
         declare
            ch : character := peek_char (ctx);
         begin
            adv_char (ctx);
            res := make_character (ch);
         end;
      else
         declare
            tok : unbounded_string := null_unbounded_string;
         begin
            while not is_eof (ctx)
              and then not is_delimiter (peek_char (ctx))
            loop
               append (tok, peek_char (ctx));
               adv_char (ctx);
            end loop;
            res := make_character (parse_named_char (to_string (tok)));
         end;
      end if;
      return res;
   end parse_character_literal;

   function parse_list_items
     (ctx : in out parse_context; lbl : in out label_context)
      return sexpr
   is
      res : sexpr := make_null;
   begin
      skip_whitespace_and_comments (ctx, lbl);
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
         skip_whitespace_and_comments (ctx, lbl);
         res := parse_datum (ctx, lbl);
         skip_whitespace_and_comments (ctx, lbl);
         if peek_char (ctx) /= ')' then
            raise parse_error with "expected ')' after dotted cdr";
         end if;
         adv_char (ctx); -- consume ')'
      else
         declare
            head : sexpr := parse_datum (ctx, lbl);
            tail : sexpr := parse_list_items (ctx, lbl);
         begin
            res := cons (head, tail);
         end;
      end if;
      return res;
   end parse_list_items;

   function parse_vector_literal
     (ctx : in out parse_context; lbl : in out label_context)
      return sexpr
   is
      temp_list : sexpr;
      vec_count : natural := 0;
      cur       : sexpr;
      res       : sexpr;
   begin
      adv_char (ctx); -- skip '('
      temp_list := parse_list_items (ctx, lbl);
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
   end parse_vector_literal;

   function parse_bytevector_literal
     (ctx : in out parse_context; lbl : in out label_context)
      return sexpr
   is
      temp_list : sexpr;
      bv_count  : natural := 0;
      cur       : sexpr;
      res       : sexpr;
   begin
      adv_char (ctx); -- skip 'u'
      adv_char (ctx); -- skip '8'
      if is_eof (ctx) or else peek_char (ctx) /= '(' then
         raise parse_error with "expected '(' after #u8";
      end if;
      adv_char (ctx); -- skip '('
      temp_list := parse_list_items (ctx, lbl);
      bv_count := length (temp_list);

      declare
         bytes : byte_array (1 .. bv_count);
         idx   : positive := 1;
      begin
         cur := temp_list;
         while is_pair (cur) loop
            declare
               val : long_long_integer := get_integer (car (cur));
            begin
               if val < 0 or val > 255 then
                  raise parse_error
                    with "bytevector element out of range";
               end if;
               bytes (idx) := interfaces.unsigned_8 (val);
            end;
            idx := idx + 1;
            cur := cdr (cur);
         end loop;
         res := make_bytevector (bytes);
      end;
      return res;
   end parse_bytevector_literal;

   function is_valid_integer
     (tok : in string; rad : in positive) return boolean
   is
      res : boolean := true;
      st  : positive := tok'first;
   begin
      if tok'length = 0 then
         res := false;
      else
         if tok (st) = '+' or tok (st) = '-' then
            st := st + 1;
         end if;
         if st > tok'last then
            res := false;
         else
            for i in st .. tok'last loop
               if rad = 10 and then not (tok (i) in '0' .. '9') then
                  res := false;
               elsif rad = 16
                 and then not (tok (i) in '0' .. '9'
                               or else tok (i) in 'a' .. 'f'
                               or else tok (i) in 'A' .. 'F')
               then
                  res := false;
               elsif rad = 8 and then not (tok (i) in '0' .. '7') then
                  res := false;
               elsif rad = 2 and then not (tok (i) in '0' .. '1') then
                  res := false;
               end if;
            end loop;
         end if;
      end if;
      return res;
   end is_valid_integer;

   function parse_int_val
     (tok : in string; rad : in positive) return long_long_integer
   is
      neg : boolean := false;
      val : long_long_integer := 0;
      st  : positive := tok'first;
   begin
      if tok (st) = '-' then
         neg := true;
         st := st + 1;
      elsif tok (st) = '+' then
         st := st + 1;
      end if;

      for i in st .. tok'last loop
         declare
            d : natural := parse_hex_digit (tok (i));
         begin
            val :=
              val * long_long_integer (rad) + long_long_integer (d);
         end;
      end loop;

      if neg then
         val := -val;
      end if;
      return val;
   end parse_int_val;

   function parse_number_or_symbol
     (raw_tok : in string; radix : in positive := 10) return sexpr
   is
      tok : string := raw_tok;
      res : sexpr;
   begin
      --if tok = "+inf.0" then
      --   res := make_real (long_float'last);
      --elsif tok = "-inf.0" then
      --   res := make_real (long_float'first);
      --elsif tok = "+nan.0" or else tok = "-nan.0" then
      --   res := make_real (0.0 / 0.0);
      if is_valid_integer (tok, radix) then
         res := make_integer (parse_int_val (tok, radix));
      elsif index (tok, "/") > 0 then
         declare
            slash_pos : natural := index (tok, "/");
            num_str   : string := tok (tok'first .. slash_pos - 1);
            den_str   : string := tok (slash_pos + 1 .. tok'last);
         begin
            if is_valid_integer (num_str, radix)
              and then is_valid_integer (den_str, radix)
            then
               declare
                  n : long_long_integer :=
                    parse_int_val (num_str, radix);
                  d : long_long_integer :=
                    parse_int_val (den_str, radix);
               begin
                  if d > 0 then
                     res := make_rational (n, d);
                  else
                     res := make_symbol (tok);
                  end if;
               end;
            else
               res := make_symbol (tok);
            end if;
         end;
      else
         begin
            declare
               rf : long_float := long_float'value (tok);
            begin
               res := make_real (rf);
            end;
         exception
            when others =>
               res := make_symbol (tok);
         end;
      end if;
      return res;
   end parse_number_or_symbol;

   function parse_hash_prefix
     (ctx : in out parse_context; lbl : in out label_context)
      return sexpr
   is
      res : sexpr;
   begin
      adv_char (ctx); -- skip '#'
      if is_eof (ctx) then
         raise parse_error with "unexpected eof after '#'";
      end if;

      declare
         c : character := peek_char (ctx);
      begin
         if c = 't' or else c = 'T' then
            adv_char (ctx);
            if not is_eof (ctx)
              and then (peek_char (ctx) = 'r'
                        or else peek_char (ctx) = 'R')
            then
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  adv_char (ctx);
               end loop;
            end if;
            res := make_boolean (true);
         elsif c = 'f' or else c = 'F' then
            adv_char (ctx);
            if not is_eof (ctx)
              and then (peek_char (ctx) = 'a'
                        or else peek_char (ctx) = 'A')
            then
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  adv_char (ctx);
               end loop;
            end if;
            res := make_boolean (false);
         elsif c = '\' then
            res := parse_character_literal (ctx);
         elsif c = '(' then
            res := parse_vector_literal (ctx, lbl);
         elsif c = 'u' and then peek_next_char (ctx) = '8' then
            res := parse_bytevector_literal (ctx, lbl);
         elsif c = 'b' or else c = 'B' then
            adv_char (ctx);
            declare
               tok : unbounded_string := null_unbounded_string;
            begin
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  append (tok, peek_char (ctx));
                  adv_char (ctx);
               end loop;
               res := parse_number_or_symbol (to_string (tok), 2);
            end;
         elsif c = 'o' or else c = 'O' then
            adv_char (ctx);
            declare
               tok : unbounded_string := null_unbounded_string;
            begin
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  append (tok, peek_char (ctx));
                  adv_char (ctx);
               end loop;
               res := parse_number_or_symbol (to_string (tok), 8);
            end;
         elsif c = 'x' or else c = 'X' then
            adv_char (ctx);
            declare
               tok : unbounded_string := null_unbounded_string;
            begin
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  append (tok, peek_char (ctx));
                  adv_char (ctx);
               end loop;
               res := parse_number_or_symbol (to_string (tok), 16);
            end;
         elsif c = 'd'
           or else c = 'D'
           or else c = 'e'
           or else c = 'E'
           or else c = 'i'
           or else c = 'I'
         then
            adv_char (ctx);
            declare
               tok : unbounded_string := null_unbounded_string;
            begin
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  append (tok, peek_char (ctx));
                  adv_char (ctx);
               end loop;
               res := parse_number_or_symbol (to_string (tok), 10);
            end;
         elsif c in '0' .. '9' then
            declare
               lbl_num : natural := 0;
            begin
               while not is_eof (ctx)
                 and then peek_char (ctx) in '0' .. '9'
               loop
                  lbl_num :=
                    lbl_num
                    * 10
                    + (character'pos (peek_char (ctx))
                       - character'pos ('0'));
                  adv_char (ctx);
               end loop;
               if not is_eof (ctx) and then peek_char (ctx) = '=' then
                  adv_char (ctx);
                  res := parse_datum (ctx, lbl);
                  if lbl.count < lbl.entries'last then
                     lbl.count := lbl.count + 1;
                     lbl.entries (lbl.count).id := lbl_num;
                     lbl.entries (lbl.count).val := res;
                  end if;
               elsif not is_eof (ctx) and then peek_char (ctx) = '#'
               then
                  adv_char (ctx);
                  declare
                     found : boolean := false;
                  begin
                     for idx in 1 .. lbl.count loop
                        if lbl.entries (idx).id = lbl_num then
                           res := lbl.entries (idx).val;
                           found := true;
                        end if;
                     end loop;
                     if not found then
                        raise parse_error
                          with
                            "unknown datum label #"
                            & natural'image (lbl_num)
                            & "#";
                     end if;
                  end;
               else
                  raise parse_error with "malformed datum label syntax";
               end if;
            end;
         else
            raise parse_error with "unrecognized hash token #" & c;
         end if;
      end;
      return res;
   end parse_hash_prefix;

   function parse_datum
     (ctx : in out parse_context; lbl : in out label_context)
      return sexpr
   is
      res : sexpr := make_null;
   begin
      skip_whitespace_and_comments (ctx, lbl);
      if is_eof (ctx) then
         raise parse_error with "unexpected end of file";
      end if;

      declare
         c : character := peek_char (ctx);
      begin
         if c = '(' then
            adv_char (ctx);
            res := parse_list_items (ctx, lbl);
         elsif c = '"' then
            res := parse_string_literal (ctx);
         elsif c = '|' then
            res := parse_vertical_symbol (ctx);
         elsif c = '#' then
            res := parse_hash_prefix (ctx, lbl);
         elsif c = ''' then
            adv_char (ctx);
            declare
               sub : sexpr := parse_datum (ctx, lbl);
            begin
               res :=
                 cons (make_symbol ("quote"), cons (sub, make_null));
            end;
         elsif c = '`' then
            adv_char (ctx);
            declare
               sub : sexpr := parse_datum (ctx, lbl);
            begin
               res :=
                 cons
                   (make_symbol ("quasiquote"), cons (sub, make_null));
            end;
         elsif c = ',' then
            adv_char (ctx);
            if not is_eof (ctx) and then peek_char (ctx) = '@' then
               adv_char (ctx);
               declare
                  sub : sexpr := parse_datum (ctx, lbl);
               begin
                  res :=
                    cons
                      (make_symbol ("unquote-splicing"),
                       cons (sub, make_null));
               end;
            else
               declare
                  sub : sexpr := parse_datum (ctx, lbl);
               begin
                  res :=
                    cons
                      (make_symbol ("unquote"), cons (sub, make_null));
               end;
            end if;
         else
            declare
               tok : unbounded_string := null_unbounded_string;
            begin
               while not is_eof (ctx)
                 and then not is_delimiter (peek_char (ctx))
               loop
                  append (tok, peek_char (ctx));
                  adv_char (ctx);
               end loop;
               res := parse_number_or_symbol (to_string (tok));
            end;
         end if;
      end;
      return res;
   end parse_datum;

   function read_from_string (src : in string) return sexpr is
      ctx : parse_context;
      lbl : label_context;
      res : sexpr;
   begin
      ctx.src := to_unbounded_string (src);
      ctx.pos := 1;
      ctx.len := length (ctx.src);
      res := parse_datum (ctx, lbl);
      return res;
   end read_from_string;

   function read_from_string (src : in unbounded_string) return sexpr is
      res : sexpr := read_from_string (to_string (src));
   begin
      return res;
   end read_from_string;

   function read_all_from_string (src : in string) return sexpr_array is
      ctx       : parse_context;
      lbl       : label_context;
      temp_list : sexpr := make_null;
      cnt       : natural := 0;
   begin
      ctx.src := to_unbounded_string (src);
      ctx.pos := 1;
      ctx.len := length (ctx.src);

      skip_whitespace_and_comments (ctx, lbl);
      while not is_eof (ctx) loop
         declare
            d : sexpr := parse_datum (ctx, lbl);
         begin
            temp_list := cons (d, temp_list);
            cnt := cnt + 1;
         end;
         skip_whitespace_and_comments (ctx, lbl);
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

   function read_file_content (file_path : in string) return string is
      file : ada.text_io.file_type;
      buf  : unbounded_string := null_unbounded_string;
   begin
      begin
         ada.text_io.open (file, ada.text_io.in_file, file_path);
      exception
         when others =>
            raise io_error
              with "cannot open file for reading: " & file_path;
      end;

      while not ada.text_io.end_of_file (file) loop
         declare
            line : string := ada.text_io.get_line (file);
         begin
            append (buf, line);
            append (buf, ascii.lf);
         end;
      end loop;
      ada.text_io.close (file);
      return to_string (buf);
   end read_file_content;

   function read_from_file (file_path : in string) return sexpr is
      content : string := read_file_content (file_path);
      res     : sexpr := read_from_string (content);
   begin
      return res;
   end read_from_file;

   function read_all_from_file
     (file_path : in string) return sexpr_array
   is
      content : string := read_file_content (file_path);
   begin
      return read_all_from_string (content);
   end read_all_from_file;

   ---------------------------------------------------------------------
   -- Serialization (write, write-simple, display)
   ---------------------------------------------------------------------

   procedure serialize_datum
     (e       : in sexpr;
      display : in boolean;
      buf     : in out unbounded_string);

   procedure serialize_string
     (str     : in unbounded_string;
      display : in boolean;
      buf     : in out unbounded_string) is
   begin
      if display then
         append (buf, str);
      else
         append (buf, '"');
         for i in 1 .. length (str) loop
            declare
               c : character := element (str, i);
            begin
               case c is
                  when '"'      =>
                     append (buf, "\""");

                  when '\'      =>
                     append (buf, "\\");

                  when ascii.lf =>
                     append (buf, "\n");

                  when ascii.ht =>
                     append (buf, "\t");

                  when ascii.cr =>
                     append (buf, "\r");

                  when others   =>
                     append (buf, c);
               end case;
            end;
         end loop;
         append (buf, '"');
      end if;
   end serialize_string;

   procedure serialize_character
     (ch      : in wide_wide_character;
      display : in boolean;
      buf     : in out unbounded_string)
   is
      code : natural := wide_wide_character'pos (ch);
   begin
      if display then
         if code <= 255 then
            append (buf, character'val (code));
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
               append (buf, character'val (code));

            when others    =>
               append (buf, "x");
               declare
                  hex_str : string := natural'image (code);
               begin
                  append (buf, hex_str (2 .. hex_str'last));
                  append (buf, ";");
               end;
         end case;
      end if;
   end serialize_character;

   procedure serialize_list
     (e : in sexpr; display : in boolean; buf : in out unbounded_string)
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
     (e : in sexpr; display : in boolean; buf : in out unbounded_string)
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
     (e : in sexpr; buf : in out unbounded_string)
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
            s_val : string := interfaces.unsigned_8'image (b_val);
         begin
            append (buf, s_val (2 .. s_val'last));
         end;
      end loop;
      append (buf, ')');
   end serialize_bytevector;

   procedure serialize_datum
     (e : in sexpr; display : in boolean; buf : in out unbounded_string)
   is
   begin
      if is_null (e) then
         append (buf, "()");
      else
         case e.ptr.kind is
            when kind_null       =>
               append (buf, "()");

            when kind_boolean    =>
               if e.ptr.bool_val then
                  append (buf, "#t");
               else
                  append (buf, "#f");
               end if;

            when kind_integer    =>
               declare
                  s : string := long_long_integer'image (e.ptr.int_val);
               begin
                  if s (1) = ' ' then
                     append (buf, s (2 .. s'last));
                  else
                     append (buf, s);
                  end if;
               end;

            when kind_real       =>
               declare
                  s : string := long_float'image (e.ptr.real_val);
               begin
                  if s (1) = ' ' then
                     append (buf, s (2 .. s'last));
                  else
                     append (buf, s);
                  end if;
               end;

            when kind_rational   =>
               declare
                  ns : string :=
                    long_long_integer'image (e.ptr.num_val);
                  ds : string :=
                    long_long_integer'image (e.ptr.den_val);
               begin
                  if ns (1) = ' ' then
                     append (buf, ns (2 .. ns'last));
                  else
                     append (buf, ns);
                  end if;
                  append (buf, "/");
                  if ds (1) = ' ' then
                     append (buf, ds (2 .. ds'last));
                  else
                     append (buf, ds);
                  end if;
               end;

            when kind_character  =>
               serialize_character (e.ptr.char_val, display, buf);

            when kind_string     =>
               serialize_string (e.ptr.str_val, display, buf);

            when kind_symbol     =>
               append (buf, e.ptr.sym_val);

            when kind_pair       =>
               serialize_list (e, display, buf);

            when kind_vector     =>
               serialize_vector (e, display, buf);

            when kind_bytevector =>
               serialize_bytevector (e, buf);
         end case;
      end if;
   end serialize_datum;

   function write_to_string (e : in sexpr) return unbounded_string is
      buf : unbounded_string := null_unbounded_string;
   begin
      serialize_datum (e, false, buf);
      return buf;
   end write_to_string;

   function write_to_string (e : in sexpr) return string is
      res : string := to_string (write_to_string (e));
   begin
      return res;
   end write_to_string;

   function write_simple_to_string (e : in sexpr) return string is
      res : string := write_to_string (e);
   begin
      return res;
   end write_simple_to_string;

   function display_to_string (e : in sexpr) return string is
      buf : unbounded_string := null_unbounded_string;
   begin
      serialize_datum (e, true, buf);
      return to_string (buf);
   end display_to_string;

   procedure write_to_file (e : in sexpr; file_path : in string) is
      file : ada.text_io.file_type;
   begin
      begin
         ada.text_io.create (file, ada.text_io.out_file, file_path);
      exception
         when others =>
            raise io_error
              with "cannot create file for writing: " & file_path;
      end;
      ada.text_io.put_line (file, write_to_string (e));
      ada.text_io.close (file);
   end write_to_file;

   procedure display_to_file (e : in sexpr; file_path : in string) is
      file : ada.text_io.file_type;
   begin
      begin
         ada.text_io.create (file, ada.text_io.out_file, file_path);
      exception
         when others =>
            raise io_error
              with "cannot create file for writing: " & file_path;
      end;
      ada.text_io.put_line (file, display_to_string (e));
      ada.text_io.close (file);
   end display_to_file;

end r7rs_sexpr;

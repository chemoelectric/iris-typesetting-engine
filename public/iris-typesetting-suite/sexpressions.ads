--  sexpressions.ads --- R7RS Scheme S-Expression I/O for Ada 2022
--
--  SPDX-License-Identifier: MIT

--
-- FIXME: RENAME ARGUMENTS TO BE LIKE THOSE OF STANDARD ADA LIBRARIES.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.numerics.big_numbers.big_integers;
with ada.numerics.big_numbers.big_reals;
with ada.wide_wide_characters;
with ada.wide_wide_characters.handling;
with ada.strings.wide_wide_unbounded;
with ada.strings.wide_wide_hash;
with ada.containers;
with ada.finalization;
with interfaces;

package sexpressions is

   package bignum_integers renames
     ada.numerics.big_numbers.big_integers;
   package exact_reals renames ada.numerics.big_numbers.big_reals;

   subtype fixnum_integer is long_long_integer;
   subtype bignum_integer is bignum_integers.big_integer;
   subtype exact_real is exact_reals.big_real;
   subtype inexact_real is long_float;

   package exact_reals_conversions is new
     exact_reals.float_conversions (num => inexact_real);

   package sexpr_characters renames ada.wide_wide_characters;
   package sexpr_characters_handling renames
     ada.wide_wide_characters.handling;
   subtype sexpr_character is wide_wide_character;

   function is_ascii (item : sexpr_character) return boolean
   with global => null;
   function is_binary_digit (item : in sexpr_character) return boolean
   with global => null;
   function is_octal_digit (item : in sexpr_character) return boolean
   with global => null;
   function is_ascii_digit (item : in sexpr_character) return boolean
   with global => null;
   function is_hexadecimal_digit
     (item : in sexpr_character) return boolean
   renames sexpr_characters_handling.is_hexadecimal_digit;

   package sexpr_strings renames ada.strings.wide_wide_unbounded;
   subtype sexpr_fixstr is wide_wide_string;
   subtype sexpr_string is sexpr_strings.unbounded_wide_wide_string;

   type sexpr_character_array is
     array (positive range <>) of sexpr_character;
   type sexpr_string_array is array (positive range <>) of sexpr_string;

   function is_member
     (item : in sexpr_character; in_array : in sexpr_character_array)
      return boolean
   with post => in_array'length /= 0 or not is_member'result;

   function is_member
     (item : in sexpr_string; in_array : in sexpr_string_array)
      return boolean
   with post => in_array'length /= 0 or not is_member'result;

   null_sexpr_fixstr : constant sexpr_fixstr := sexpr_fixstr'("");
   null_sexpr_string : constant sexpr_string :=
     sexpr_strings.null_unbounded_wide_wide_string;

   function to_sexpr_fixstr (source : in string) return sexpr_fixstr;
   function to_sexpr_string (source : in string) return sexpr_string;

   function to_sexpr_fixstr
     (source : in sexpr_string) return sexpr_fixstr
   renames sexpr_strings.to_wide_wide_string;

   function to_sexpr_string
     (source : in sexpr_fixstr) return sexpr_string
   renames sexpr_strings.to_unbounded_wide_wide_string;

   function to_string (source : in sexpr_fixstr) return string;
   function to_string (source : in sexpr_string) return string;

   function to_lower (item : in sexpr_string) return sexpr_string
   with global => null;
   function to_upper (item : in sexpr_string) return sexpr_string
   with global => null;

   function hash (key : in sexpr_fixstr) return ada.containers.hash_type
   renames ada.strings.wide_wide_hash;
   function hash
     (key : in sexpr_string) return ada.containers.hash_type;

   type sexpr_kind is
     (kind_null,
      kind_boolean,
      kind_integer,
      kind_inexact,
      kind_rational,
      kind_character,
      kind_string,
      kind_symbol,
      kind_pair,
      kind_vector,
      kind_bytevector);

   type byte_array is
     array (positive range <>) of interfaces.unsigned_8;

   type sexpr is new ada.finalization.controlled with private;

   type sexpr_array is array (positive range <>) of sexpr;

   parse_error : exception;
   type_error  : exception;
   io_error    : exception;

   procedure ignore (item : sexpr);

   function make_null return sexpr;
   function make_boolean (val : in boolean) return sexpr;
   function make_integer (val : in bignum_integer) return sexpr;
   function make_inexact (val : in inexact_real) return sexpr;
   function make_exact (val : in exact_real) return sexpr;
   function make_exact
     (num : in bignum_integer; den : in bignum_integer) return sexpr;
   function make_character (ch : in sexpr_character) return sexpr;
   function make_string (str : in sexpr_string) return sexpr;
   function make_string (str : in wide_wide_string) return sexpr;
   function make_symbol (sym : in sexpr_string) return sexpr;
   function make_symbol (sym : in wide_wide_string) return sexpr;
   function to_exact (e : in sexpr) return sexpr;
   function to_inexact (e : in sexpr) return sexpr;
   function cons (car_val : in sexpr; cdr_val : in sexpr) return sexpr;
   function make_list (items : in sexpr_array) return sexpr;
   function make_vector (items : in sexpr_array) return sexpr;
   function make_bytevector (bytes : in byte_array) return sexpr;
   function kind (e : in sexpr) return sexpr_kind;
   function is_null (e : in sexpr) return boolean;
   function is_boolean (e : in sexpr) return boolean;
   function is_integer (e : in sexpr) return boolean;
   function is_inexact (e : in sexpr) return boolean;
   function is_exact (e : in sexpr) return boolean;
   function is_number (e : in sexpr) return boolean;
   function is_character (e : in sexpr) return boolean;
   function is_string (e : in sexpr) return boolean;
   function is_symbol (e : in sexpr) return boolean;
   function is_pair (e : in sexpr) return boolean;
   function is_list (e : in sexpr) return boolean;
   function is_vector (e : in sexpr) return boolean;
   function is_bytevector (e : in sexpr) return boolean;
   function get_boolean (e : in sexpr) return boolean;
   function get_integer (e : in sexpr) return bignum_integer;
   function get_inexact (e : in sexpr) return inexact_real;
   function get_exact (e : in sexpr) return exact_real;
   function get_numerator (e : in sexpr) return bignum_integer;
   function get_denominator (e : in sexpr) return bignum_integer;
   function get_character (e : in sexpr) return sexpr_character;
   function get_string (e : in sexpr) return sexpr_string;
   function get_symbol (e : in sexpr) return sexpr_string;
   function car (e : in sexpr) return sexpr;
   function cdr (e : in sexpr) return sexpr;
   function caar (e : in sexpr) return sexpr;
   function cadr (e : in sexpr) return sexpr;
   function cdar (e : in sexpr) return sexpr;
   function cddr (e : in sexpr) return sexpr;
   function length (e : in sexpr) return natural;
   function list_ref (e : in sexpr; idx : in positive) return sexpr;
   function vector_length (e : in sexpr) return natural;
   function vector_ref (e : in sexpr; idx : in positive) return sexpr;
   function bytevector_length (e : in sexpr) return natural;
   function bytevector_ref
     (e : in sexpr; idx : in positive) return interfaces.unsigned_8;
   function equal (left : in sexpr; right : in sexpr) return boolean;
   function eqv (left : in sexpr; right : in sexpr) return boolean;
   function assoc (key : in sexpr; alist : in sexpr) return sexpr;
   function assq (key : in sexpr_fixstr; alist : in sexpr) return sexpr;
   function acons
     (key : in sexpr; val : in sexpr; alist : in sexpr) return sexpr;
   function read_from_string (source : in sexpr_string) return sexpr;
   function read_from_string
     (source : in wide_wide_string) return sexpr;
   function read (file_path : in string) return sexpr;
   function read_all_from_string
     (source : in sexpr_string) return sexpr_array;
   function read_all (file_path : in string) return sexpr_array;
   --
   -- FIXME: write_to_string requires detection of circular lists.
   --
   -- function write_to_string (e : in sexpr) return sexpr_string;
   --
   function write_simple_to_string (e : in sexpr) return sexpr_string;
   --
   -- FIXME: display_to_string requires detection of circular lists.
   --
   function display_to_string (e : in sexpr) return sexpr_string;
   --
   -- FIXME: write requires detection of circular lists.
   --
   -- procedure write (e : in sexpr; file_path : in string);
   --
   procedure write_simple (e : in sexpr; file_path : in string);
   --
   -- FIXME: display requires detection of circular lists.
   --
   procedure display (e : in sexpr; file_path : in string);

private

   type sexpr_vector_access is access all sexpr_array;
   type byte_vector_access is access all byte_array;

   type node_record (kind : sexpr_kind := kind_null) is record
      reference_count : natural := 1;
      case kind is
         when kind_null =>
            null;

         when kind_boolean =>
            boolean_val : boolean;

         when kind_integer =>
            integer_val : bignum_integer;

         when kind_inexact =>
            inexact_val : inexact_real;

         when kind_rational =>
            rational_val : exact_real;

         when kind_character =>
            character_val : sexpr_character;

         when kind_string =>
            string_val : sexpr_string;

         when kind_symbol =>
            symbol_val : sexpr_string;

         when kind_pair =>
            car_val : sexpr;
            cdr_val : sexpr;

         when kind_vector =>
            vector_val : sexpr_vector_access;

         when kind_bytevector =>
            bytevector_val : byte_vector_access;
      end case;
   end record;

   type node_access is access all node_record;

   type sexpr is new ada.finalization.controlled with record
      ptr : node_access := null;
   end record;

   overriding
   procedure adjust (obj : in out sexpr);
   overriding
   procedure finalize (obj : in out sexpr);

end sexpressions;

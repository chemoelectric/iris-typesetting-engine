--  sexpressions.ads --- R7RS Scheme S-Expression I/O for Ada 2022
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.numerics.big_numbers.big_integers;
with ada.numerics.big_numbers.big_reals;
with ada.wide_wide_characters;
with ada.wide_wide_characters.handling;
with ada.strings.wide_wide_unbounded;
with ada.strings.wide_wide_hash;
with ada.containers.vectors;
with ada.containers.indefinite_vectors;
with ada.containers;         use ada.containers;
with ada.finalization;       use ada.finalization;
with interfaces;             use interfaces;
with sequential_identifiers; use sequential_identifiers;

package sexpressions is

   parse_error : exception;
   type_error  : exception;
   io_error    : exception;

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

   function hash_sexpr_fixstr (key : in sexpr_fixstr) return hash_type
   renames ada.strings.wide_wide_hash;
   function hash_sexpr_string (key : in sexpr_string) return hash_type;

   ---------------------------------------------------------------------

   type sexpr_kind is
     (sexpr_kind_null,
      sexpr_kind_boolean,
      sexpr_kind_integer,
      sexpr_kind_inexact,
      sexpr_kind_rational,
      sexpr_kind_character,
      sexpr_kind_string,
      sexpr_kind_symbol,
      sexpr_kind_pair,
      sexpr_kind_vector,
      sexpr_kind_bytevector);

   ---------------------------------------------------------------------

   subtype sexpr_identifier is sequential_identifier;

   function hash_sexpr_identifier
     (key : in sexpr_identifier) return hash_type
   renames hash_sequential_identifier;

   function sexpr_identifier_equivalents
     (left, right : in sexpr_identifier) return boolean
   renames sequential_identifiers."=";

   package sexpr_identifier_vectors is new
     indefinite_vectors
       (index_type   => positive,
        element_type => sexpr_identifier,
        "="          => "=");
   subtype sexpr_identifier_vector is sexpr_identifier_vectors.vector;

   ---------------------------------------------------------------------

   type sexpr is new controlled with record
      identifier : sexpr_identifier;
   end record;

   overriding
   procedure adjust (object : in out sexpr);
   overriding
   procedure finalize (object : in out sexpr);

   function hash_sexpr (key : in sexpr) return hash_type;
   function sexpr_equivalents (left, right : in sexpr) return boolean;

   package sexpr_vectors is new
     indefinite_vectors
       (index_type   => positive,
        element_type => sexpr,
        "="          => "=");
   subtype sexpr_vector is sexpr_vectors.vector;

   ---------------------------------------------------------------------

   package unsigned_8_vectors is new
     vectors
       (index_type   => positive,
        element_type => interfaces.unsigned_8,
        "="          => "=");
   subtype unsigned_8_vector is unsigned_8_vectors.vector;

   ---------------------------------------------------------------------

   procedure ignore (item : sexpr);

   ---------------------------------------------------------------------

   function make_null return sexpr;
   function make_boolean (item : in boolean) return sexpr;
   function make_integer (item : in bignum_integer) return sexpr;
   function make_inexact (item : in inexact_real) return sexpr;
   function make_exact (item : in exact_real) return sexpr;
   function make_exact
     (numerator, denominator : in bignum_integer) return sexpr;
   function make_character (item : in sexpr_character) return sexpr;
   function make_string (source : in sexpr_fixstr) return sexpr;
   function make_string (source : in sexpr_string) return sexpr;
   function make_symbol (source : in sexpr_fixstr) return sexpr;
   function make_symbol (source : in sexpr_string) return sexpr;
   function to_exact (item : in sexpr) return sexpr;
   function to_inexact (item : in sexpr) return sexpr;
   function cons (car : in sexpr; cdr : in sexpr) return sexpr;
   function make_list (source : in sexpr_vector) return sexpr;
   function make_circular_list (source : in sexpr_vector) return sexpr;
   function make_vector (source : in sexpr_vector) return sexpr;
   function make_bytevector
     (source : in unsigned_8_vector) return sexpr;
   function kind (item : in sexpr) return sexpr_kind;
   function is_null (item : in sexpr) return boolean;
   function is_boolean (item : in sexpr) return boolean;
   function is_integer (item : in sexpr) return boolean;
   function is_inexact (item : in sexpr) return boolean;
   function is_exact (item : in sexpr) return boolean;
   function is_number (item : in sexpr) return boolean;
   function is_character (item : in sexpr) return boolean;
   function is_string (item : in sexpr) return boolean;
   function is_symbol (item : in sexpr) return boolean;
   function is_pair (item : in sexpr) return boolean;
   function is_list (item : in sexpr) return boolean;
   function is_vector (item : in sexpr) return boolean;
   function is_bytevector (item : in sexpr) return boolean;
   function get_boolean (item : in sexpr) return boolean;
   function get_integer (item : in sexpr) return bignum_integer;
   function get_inexact (item : in sexpr) return inexact_real;
   function get_exact (item : in sexpr) return exact_real;
   function get_numerator (item : in sexpr) return bignum_integer;
   function get_denominator (item : in sexpr) return bignum_integer;
   function get_character (item : in sexpr) return sexpr_character;
   function get_string (item : in sexpr) return sexpr_string;
   function get_symbol (item : in sexpr) return sexpr_string;
   function car (item : in sexpr) return sexpr;
   function cdr (item : in sexpr) return sexpr;
   function caar (item : in sexpr) return sexpr;
   function cadr (item : in sexpr) return sexpr;
   function cdar (item : in sexpr) return sexpr;
   function cddr (item : in sexpr) return sexpr;
   function length (item : in sexpr) return natural;
   function list_ref
     (item : in sexpr; index : in positive) return sexpr;
   procedure set_car (pair, value : sexpr);
   procedure set_cdr (pair, value : sexpr);
   function vector_length (item : in sexpr) return natural;
   function vector_ref
     (item : in sexpr; index : in positive) return sexpr;
   function bytevector_length (item : in sexpr) return natural;
   function bytevector_ref
     (item : in sexpr; index : in positive)
      return interfaces.unsigned_8;
   function equal (left, right : in sexpr) return boolean;
   function eqv (left, right : in sexpr) return boolean;
   function assoc (key, alist : in sexpr) return sexpr;
   function assq (key : in sexpr_fixstr; alist : in sexpr) return sexpr;
   function acons (key, val, alist : in sexpr) return sexpr;

   ---------------------------------------------------------------------

   function read_from_string (source : in sexpr_string) return sexpr;
   function read_from_string (source : in sexpr_fixstr) return sexpr;
   function read (filename : in string) return sexpr;
   function read_all_from_string
     (source : in sexpr_string) return sexpr_vector;
   function read_all (filename : in string) return sexpr_vector;

   ---------------------------------------------------------------------

   function write_to_string (item : in sexpr) return sexpr_string;
   function write_simple_to_string
     (item : in sexpr) return sexpr_string;
   --
   -- FIXME: display_to_string requires detection of circular lists.
   --
   function display_to_string (item : in sexpr) return sexpr_string;
   --
   -- FIXME: write requires detection of circular lists.
   --
   -- procedure write (item : in sexpr; filename : in string);
   --
   procedure write_simple (item : in sexpr; filename : in string);
   --
   -- FIXME: display requires detection of circular lists.
   --
   procedure display (item : in sexpr; filename : in string);

   ---------------------------------------------------------------------

end sexpressions;

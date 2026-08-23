pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;

package bits_stdint_least_h is

   subtype int_least8_t is bits_types_h.uu_int_least8_t;  -- /usr/local/include/bits/stdint-least.h:25

   subtype int_least16_t is bits_types_h.uu_int_least16_t;  -- /usr/local/include/bits/stdint-least.h:26

   subtype int_least32_t is bits_types_h.uu_int_least32_t;  -- /usr/local/include/bits/stdint-least.h:27

   subtype int_least64_t is bits_types_h.uu_int_least64_t;  -- /usr/local/include/bits/stdint-least.h:28

   subtype uint_least8_t is bits_types_h.uu_uint_least8_t;  -- /usr/local/include/bits/stdint-least.h:31

   subtype uint_least16_t is bits_types_h.uu_uint_least16_t;  -- /usr/local/include/bits/stdint-least.h:32

   subtype uint_least32_t is bits_types_h.uu_uint_least32_t;  -- /usr/local/include/bits/stdint-least.h:33

   subtype uint_least64_t is bits_types_h.uu_uint_least64_t;  -- /usr/local/include/bits/stdint-least.h:34

end bits_stdint_least_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");

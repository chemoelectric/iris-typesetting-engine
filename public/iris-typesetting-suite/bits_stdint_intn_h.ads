pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;

package bits_stdint_intn_h is

   subtype int8_t is bits_types_h.uu_int8_t;  -- /usr/local/include/bits/stdint-intn.h:24

   subtype int16_t is bits_types_h.uu_int16_t;  -- /usr/local/include/bits/stdint-intn.h:25

   subtype int32_t is bits_types_h.uu_int32_t;  -- /usr/local/include/bits/stdint-intn.h:26

   subtype int64_t is bits_types_h.uu_int64_t;  -- /usr/local/include/bits/stdint-intn.h:27

end bits_stdint_intn_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");

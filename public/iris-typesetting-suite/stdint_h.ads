pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;

package stdint_h is

   INT8_MIN : constant := (-128);  --  /usr/local/include/stdint.h:105
   INT16_MIN : constant := (-32767-1);  --  /usr/local/include/stdint.h:106
   INT32_MIN : constant := (-2147483647-1);  --  /usr/local/include/stdint.h:107
   --  unsupported macro: INT64_MIN (-__INT64_C(9223372036854775807)-1)

   INT8_MAX : constant := (127);  --  /usr/local/include/stdint.h:110
   INT16_MAX : constant := (32767);  --  /usr/local/include/stdint.h:111
   INT32_MAX : constant := (2147483647);  --  /usr/local/include/stdint.h:112
   --  unsupported macro: INT64_MAX (__INT64_C(9223372036854775807))

   UINT8_MAX : constant := (255);  --  /usr/local/include/stdint.h:116
   UINT16_MAX : constant := (65535);  --  /usr/local/include/stdint.h:117
   UINT32_MAX : constant := (4294967295);  --  /usr/local/include/stdint.h:118
   --  unsupported macro: UINT64_MAX (__UINT64_C(18446744073709551615))

   INT_LEAST8_MIN : constant := (-128);  --  /usr/local/include/stdint.h:123
   INT_LEAST16_MIN : constant := (-32767-1);  --  /usr/local/include/stdint.h:124
   INT_LEAST32_MIN : constant := (-2147483647-1);  --  /usr/local/include/stdint.h:125
   --  unsupported macro: INT_LEAST64_MIN (-__INT64_C(9223372036854775807)-1)

   INT_LEAST8_MAX : constant := (127);  --  /usr/local/include/stdint.h:128
   INT_LEAST16_MAX : constant := (32767);  --  /usr/local/include/stdint.h:129
   INT_LEAST32_MAX : constant := (2147483647);  --  /usr/local/include/stdint.h:130
   --  unsupported macro: INT_LEAST64_MAX (__INT64_C(9223372036854775807))

   UINT_LEAST8_MAX : constant := (255);  --  /usr/local/include/stdint.h:134
   UINT_LEAST16_MAX : constant := (65535);  --  /usr/local/include/stdint.h:135
   UINT_LEAST32_MAX : constant := (4294967295);  --  /usr/local/include/stdint.h:136
   --  unsupported macro: UINT_LEAST64_MAX (__UINT64_C(18446744073709551615))

   INT_FAST8_MIN : constant := (-128);  --  /usr/local/include/stdint.h:141

   INT_FAST16_MIN : constant := (-9223372036854775807-1);  --  /usr/local/include/stdint.h:143
   INT_FAST32_MIN : constant := (-9223372036854775807-1);  --  /usr/local/include/stdint.h:144
   --  unsupported macro: INT_FAST64_MIN (-__INT64_C(9223372036854775807)-1)

   INT_FAST8_MAX : constant := (127);  --  /usr/local/include/stdint.h:151

   INT_FAST16_MAX : constant := (9223372036854775807);  --  /usr/local/include/stdint.h:153
   INT_FAST32_MAX : constant := (9223372036854775807);  --  /usr/local/include/stdint.h:154
   --  unsupported macro: INT_FAST64_MAX (__INT64_C(9223372036854775807))

   UINT_FAST8_MAX : constant := (255);  --  /usr/local/include/stdint.h:162

   UINT_FAST16_MAX : constant := (18446744073709551615);  --  /usr/local/include/stdint.h:164
   UINT_FAST32_MAX : constant := (18446744073709551615);  --  /usr/local/include/stdint.h:165
   --  unsupported macro: UINT_FAST64_MAX (__UINT64_C(18446744073709551615))

   INTPTR_MIN : constant := (-9223372036854775807-1);  --  /usr/local/include/stdint.h:175
   INTPTR_MAX : constant := (9223372036854775807);  --  /usr/local/include/stdint.h:176
   UINTPTR_MAX : constant := (18446744073709551615);  --  /usr/local/include/stdint.h:177
   --  unsupported macro: INTMAX_MIN (-__INT64_C(9223372036854775807)-1)
   --  unsupported macro: INTMAX_MAX (__INT64_C(9223372036854775807))
   --  unsupported macro: UINTMAX_MAX (__UINT64_C(18446744073709551615))

   PTRDIFF_MIN : constant := (-9223372036854775807-1);  --  /usr/local/include/stdint.h:198
   PTRDIFF_MAX : constant := (9223372036854775807);  --  /usr/local/include/stdint.h:199

   SIG_ATOMIC_MIN : constant := (-2147483647-1);  --  /usr/local/include/stdint.h:211
   SIG_ATOMIC_MAX : constant := (2147483647);  --  /usr/local/include/stdint.h:212

   SIZE_MAX : constant := (18446744073709551615);  --  /usr/local/include/stdint.h:216
   --  unsupported macro: WCHAR_MIN __WCHAR_MIN
   --  unsupported macro: WCHAR_MAX __WCHAR_MAX

   WINT_MIN : constant := (0);  --  /usr/local/include/stdint.h:233
   WINT_MAX : constant := (4294967295);  --  /usr/local/include/stdint.h:234
   --  arg-macro: procedure INT8_C (c)
   --    c
   --  arg-macro: procedure INT16_C (c)
   --    c
   --  arg-macro: procedure INT32_C (c)
   --    c
   --  unsupported macro: INT64_C(c) c ## L
   --  arg-macro: procedure UINT8_C (c)
   --    c
   --  arg-macro: procedure UINT16_C (c)
   --    c
   --  unsupported macro: UINT32_C(c) c ## U
   --  unsupported macro: UINT64_C(c) c ## UL
   --  unsupported macro: INTMAX_C(c) c ## L
   --  unsupported macro: UINTMAX_C(c) c ## UL

   INT8_WIDTH : constant := 8;  --  /usr/local/include/stdint.h:267
   UINT8_WIDTH : constant := 8;  --  /usr/local/include/stdint.h:268
   INT16_WIDTH : constant := 16;  --  /usr/local/include/stdint.h:269
   UINT16_WIDTH : constant := 16;  --  /usr/local/include/stdint.h:270
   INT32_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:271
   UINT32_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:272
   INT64_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:273
   UINT64_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:274

   INT_LEAST8_WIDTH : constant := 8;  --  /usr/local/include/stdint.h:276
   UINT_LEAST8_WIDTH : constant := 8;  --  /usr/local/include/stdint.h:277
   INT_LEAST16_WIDTH : constant := 16;  --  /usr/local/include/stdint.h:278
   UINT_LEAST16_WIDTH : constant := 16;  --  /usr/local/include/stdint.h:279
   INT_LEAST32_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:280
   UINT_LEAST32_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:281
   INT_LEAST64_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:282
   UINT_LEAST64_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:283

   INT_FAST8_WIDTH : constant := 8;  --  /usr/local/include/stdint.h:285
   UINT_FAST8_WIDTH : constant := 8;  --  /usr/local/include/stdint.h:286
   --  unsupported macro: INT_FAST16_WIDTH __WORDSIZE
   --  unsupported macro: UINT_FAST16_WIDTH __WORDSIZE
   --  unsupported macro: INT_FAST32_WIDTH __WORDSIZE
   --  unsupported macro: UINT_FAST32_WIDTH __WORDSIZE

   INT_FAST64_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:291
   UINT_FAST64_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:292
   --  unsupported macro: INTPTR_WIDTH __WORDSIZE
   --  unsupported macro: UINTPTR_WIDTH __WORDSIZE

   INTMAX_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:297
   UINTMAX_WIDTH : constant := 64;  --  /usr/local/include/stdint.h:298
   --  unsupported macro: PTRDIFF_WIDTH __WORDSIZE

   SIG_ATOMIC_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:301
   --  unsupported macro: SIZE_WIDTH __WORDSIZE

   WCHAR_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:303
   WINT_WIDTH : constant := 32;  --  /usr/local/include/stdint.h:304

   subtype int_fast8_t is signed_char;  -- /usr/local/include/stdint.h:47

   subtype int_fast16_t is long;  -- /usr/local/include/stdint.h:49

   subtype int_fast32_t is long;  -- /usr/local/include/stdint.h:50

   subtype int_fast64_t is long;  -- /usr/local/include/stdint.h:51

   subtype uint_fast8_t is unsigned_char;  -- /usr/local/include/stdint.h:60

   subtype uint_fast16_t is unsigned_long;  -- /usr/local/include/stdint.h:62

   subtype uint_fast32_t is unsigned_long;  -- /usr/local/include/stdint.h:63

   subtype uint_fast64_t is unsigned_long;  -- /usr/local/include/stdint.h:64

   subtype intptr_t is long;  -- /usr/local/include/stdint.h:76

   subtype uintptr_t is unsigned_long;  -- /usr/local/include/stdint.h:79

   subtype intmax_t is bits_types_h.uu_intmax_t;  -- /usr/local/include/stdint.h:90

   subtype uintmax_t is bits_types_h.uu_uintmax_t;  -- /usr/local/include/stdint.h:91

end stdint_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");

m4_dnl  SPDX-License-Identifier: MIT
m4_dnl
m4_divert(-1)

m4_ifdef(m4_log2,`',
`m4_define(`_m4_log2_loop',`m4_ifelse(m4_eval($1 > 1),1,`m4_eval(1 + _m4_log2_loop(m4_eval($1 / 2)))',0)')
m4_define(`m4_log2',`m4_ifelse(m4_eval($1 <= 0),1,`m4_m4exit(1)',`_m4_log2_loop($1)')')')

m4_ifdef(m4_pow,`',
`m4_define(`_m4_pow_loop',`m4_ifelse($2,0,1,`m4_eval(($1) * _m4_pow_loop($1,m4_eval($2 - 1)))')')
m4_define(`m4_pow',`m4_ifelse(m4_eval($2 < 0),1,`m4_m4exit(1)',`_m4_pow_loop($1, $2)')')')

m4_divert`'m4_dnl

include(c-macros.m4)
/*
 * Copyright (c) 2026 Barry Schwartz
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

m4_divert(-1)
/*
  m4_dnl
  m4_dnl m4_unroll_search(current_offset,increment,max_size,found,body,check,set)
  m4_dnl
m4_define(«_m4_unroll_search»,«m4_ifelse(m4_eval(($1) != ($3)),0,«»,«
m4_pushdef(«_m4_offset»,«$1»)m4_dnl
  $6    if (!($5))
  $6      {m4_dnl
  $6_m4_unroll_search(m4_eval(($1) + ($2)),«$2»,«$3»,«$4»,«$5»,«$6    »)
  $6      }
  $6    else
  $6      $4«»m4_popdef(«_m4_offset»)»)»)
m4_define(«m4_unroll_search»,«_$0(«$1»,«$2»,«$3»,«$4»,«$5»,«$6»)»)

m4_divert«»m4_dnl

#ifndef «PARALLEL_SEARCH_H_»m4_VARIANT«__INCLUDED_ALREADY__»
#define «PARALLEL_SEARCH_H_»m4_VARIANT«__INCLUDED_ALREADY__»

m4_dnl
m4_dnl  Ensure that m4_BLOCKSIZE is a power of two.
m4_dnl
_Static_assert (m4_eval(m4_pow(2,m4_log2(m4_BLOCKSIZE))) == m4_BLOCKSIZE);

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

/* High-throughput parallel vector search for m4_KEYTYPE key. Executes
   on vector pipes without threads. Returns the index of the match, or
   -1 if not found. */
inline ssize_t
parallel_search_«»m4_VARIANT«»
  (const m4_KEYTYPE *keys, size_t count, m4_KEYTYPE target)
{
  ssize_t j = -1;

  if ((keys != nullptr) * (0 < count))
    {
      size_t limit = (count / (m4_BLOCKSIZE)) * (m4_BLOCKSIZE);

      ssize_t i = -(m4_BLOCKSIZE);
      while ((j == -1) * ((size_t) (i + (m4_BLOCKSIZE)) < limit))
        {
          i += (m4_BLOCKSIZE);

          /* Vector processing. */
          m4_unroll_search(0,1,(m4_BLOCKSIZE),
                           «j = i + »_m4_offset«;»,
                           «keys[i + »_m4_offset«] == target»,
                           «    »);
        }

      /* Process any leftovers (between limit and count). */
      while ((j == -1) * ((size_t) (i + 1) < count))
        {
          i += 1;
          if (keys[i] == target)
            j = i;
        }
    }

  return j;
}

#endif /* «PARALLEL_SEARCH_H_»m4_VARIANT«__INCLUDED_ALREADY__» */

/*
 * local variables:
 * mode: c
 * coding: utf-8
 * end:
 */

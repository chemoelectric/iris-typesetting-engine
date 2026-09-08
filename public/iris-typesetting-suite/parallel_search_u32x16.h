
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


#ifndef PARALLEL_SEARCH_H_u32x16__INCLUDED_ALREADY__
#define PARALLEL_SEARCH_H_u32x16__INCLUDED_ALREADY__

_Static_assert (16 == 16);

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

/* High-throughput parallel vector search for uint32_t key. Executes
   on vector pipes without threads. Returns the index of the match, or
   -1 if not found. */
inline ssize_t
parallel_search_u32x16
  (const uint32_t *keys, size_t count, uint32_t target)
{
  ssize_t j = -1;

  if ((keys != nullptr) * (0 < count))
    {
      size_t limit = (count / (16)) * (16);

      ssize_t i = -(16);
      while ((j == -1) * ((size_t) (i + (16)) < limit))
        {
          i += (16);

          /* Vector processing. */
          
          if (!(keys[i + 0] == target))
            {      
              if (!(keys[i + 1] == target))
                {          
                  if (!(keys[i + 2] == target))
                    {              
                      if (!(keys[i + 3] == target))
                        {                  
                          if (!(keys[i + 4] == target))
                            {                      
                              if (!(keys[i + 5] == target))
                                {                          
                                  if (!(keys[i + 6] == target))
                                    {                              
                                      if (!(keys[i + 7] == target))
                                        {                                  
                                          if (!(keys[i + 8] == target))
                                            {                                      
                                              if (!(keys[i + 9] == target))
                                                {                                          
                                                  if (!(keys[i + 10] == target))
                                                    {                                              
                                                      if (!(keys[i + 11] == target))
                                                        {                                                  
                                                          if (!(keys[i + 12] == target))
                                                            {                                                      
                                                              if (!(keys[i + 13] == target))
                                                                {                                                          
                                                                  if (!(keys[i + 14] == target))
                                                                    {                                                              
                                                                      if (!(keys[i + 15] == target))
                                                                        {                                                                  
                                                                        }
                                                                      else
                                                                        j = i + 15;
                                                                    }
                                                                  else
                                                                    j = i + 14;
                                                                }
                                                              else
                                                                j = i + 13;
                                                            }
                                                          else
                                                            j = i + 12;
                                                        }
                                                      else
                                                        j = i + 11;
                                                    }
                                                  else
                                                    j = i + 10;
                                                }
                                              else
                                                j = i + 9;
                                            }
                                          else
                                            j = i + 8;
                                        }
                                      else
                                        j = i + 7;
                                    }
                                  else
                                    j = i + 6;
                                }
                              else
                                j = i + 5;
                            }
                          else
                            j = i + 4;
                        }
                      else
                        j = i + 3;
                    }
                  else
                    j = i + 2;
                }
              else
                j = i + 1;
            }
          else
            j = i + 0;;
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

#endif /* PARALLEL_SEARCH_H_u32x16__INCLUDED_ALREADY__ */

/*
 * local variables:
 * mode: c
 * coding: utf-8
 * end:
 */

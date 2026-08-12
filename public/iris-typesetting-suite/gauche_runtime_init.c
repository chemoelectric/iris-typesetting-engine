// SPDX-License-Identifier: MIT

#include <gauche.h>

void
gauche_runtime_init (void)
{
  Scm_Init (GAUCHE_SIGNATURE);
}

// SPDX-License-Identifier: MIT

#include <gauche.h>

extern void gauche_iris_db_init (void);

void
gauche_runtime_init (void)
{
  Scm_Init (GAUCHE_SIGNATURE);
  gauche_iris_db_init ();
}

// SPDX-License-Identifier: MIT

#include <gauche.h>
#include <stdbool.h>

extern void gauche_iris_db_init (void);

static bool runtime_initialized = false;

void
gauche_runtime_init (void)
{
  if (!runtime_initialized)
    {
      Scm_Init (GAUCHE_SIGNATURE);
      gauche_iris_db_init ();
      runtime_initialized = true;
    }
}

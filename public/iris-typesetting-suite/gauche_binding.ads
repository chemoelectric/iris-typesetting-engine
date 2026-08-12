-- SPDX-License-Identifier: MIT
--
-- Thin binding to Gauche Scheme.
--

with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with system;

package gauche_binding
with preelaborate is

  -- Gauche core uses a uniform object model pointer.
  type ScmObj is new system.address;

  -- Gauche can return multiple values.
  type ScmObj_array is array (0 .. 63) of ScmObj;

   -- Representation of ScmEvalPacket structure.
   type ScmEvalPacket is
     record
       num_results      : int;
       results          : ScmObj_array;
       scheme_exception : ScmObj;
     end record
     with convention => c;

  -- Initializes the Gauche engine runtime environment
  procedure gauche_runtime_init
  with import,
       convention => c,
       external_name => "gauche_runtime_init";

  -- Returns the default user module execution context.
  function Scm_UserModule
  return ScmObj
  with import,
       convention => c,
       external_name => "Scm_UserModule";


  function Scm_EvalCString (str    : in chars_ptr;
                            env    : in ScmObj;
                            packet : not null access ScmEvalPacket)
  return int
  with import,
       convention => c,
       external_name => "Scm_EvalCString";

end gauche_binding;

--  Thread-safe sequential unique identifiers.
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.containers;

package sequential_identifiers is

   type sequential_identifier is private;

   function next_sequential_identifier return sequential_identifier;

   --
   -- FIXME:
   --
   -- ADD SUPPORT EVERYWHERE FOR INCREMENTAL HASHING.
   --
   -- Use SpookyHash. I ALREADY HAVE IT IN MY OWN C23 CODE, which can
   -- be used with the Ada, and can get my llm to implement it in
   -- parallel.
   --
   -- Ada seems not to do hashing terribly well, just as everyone else
   -- seems not to do it well. Hashing should be done incrementally.
   -- It is not taught this way in books, and so it is never learnt
   -- this way, despite that if you look up new hashes on the Internet
   -- for the last few decades you see only incremental ones.
   --
   -- The R⁷RS-large standard actually enshrines non-incremental
   -- hashing, indirectly by standardizing a bad SRFI. It is a rare
   -- part of R⁷RS that I reject. I use my own hash functions and hash
   -- maps.
   --
   -- Our universities teach obedience of sacred writings and the
   -- persecution of heretics. Count ourselves lucky that devising a
   -- new algorithm does not land us in prison. I am the only person I
   -- have ever seen using symmetric power basis, despite its enormous
   -- advantages. Why? Because only Bernstein basis is taught in most
   -- books as being ‘Bézier splines’.
   --
   function hash_sequential_identifier
     (key : in sequential_identifier) return ada.containers.hash_type;

private

   --
   -- A set of identifiers so large even filling and emptying memory
   -- again and again would not come close to exhausting identifiers.
   --
   type sequential_identifier is mod 2**128;

   protected type thread_safe_counter is
      procedure increment_counter_value;
      function get_counter_value return sequential_identifier;
   private
      counter_value : sequential_identifier := 0;
   end thread_safe_counter;

end sequential_identifiers;

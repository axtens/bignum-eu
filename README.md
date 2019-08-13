# bignum-eu
Steven S. Skiena's bignum.c in Euphoria.

Implements large integer arithmetic: addition, subtraction, multiplication, and division.

The original C program appears in Steve's book: ["Programming Challenges: The Programming Contest Training Manual"](http://www.amazon.com/exec/obidos/ASIN/0387001638/thealgorithmrepo/)
by Steven Skiena and Miguel Revilla, Springer-Verlag, New York 2003.

See Steve and Miguel's [website](http://www.programming-challenges.com) for additional information.

Bruce's release contains:

 * README.md - this file
 * bignum.e
 * test.ex
 * tests/ folder
 * LICENSE

Better testing and better documentation may follow.

MIT license.

New News
--------

 * power_modulus working
 * base_to_bignum
 * bignum_to_base
 * starting to use euphoria's unit testing framework 

Old News
--------

 * power_bignum
 * power_modulus (untested)
 * test.ex demonstrates calculating 2^1000 (which node and JScript won't do on the javascript version)
 * memoization on + - * / ^ mod compare
 * Divide works.


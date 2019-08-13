include bignum.e as B
include std/unittest.e

B:set_precision(400)


test_equal( "bignum_to_base", "FF", B:bignum_to_base(int_to_bignum(255),"0123456789AFBCDEF"))

test_report()

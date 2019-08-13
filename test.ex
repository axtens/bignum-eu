--with trace
include bignum.e as B
trace(1)


B:set_precision(5)

sequence d1 = B:int_to_bignum(11)
sequence d2 = B:int_to_bignum(90)
sequence d3 = B:divide_bignum(d2,d1)
B:print_bignum(d3)



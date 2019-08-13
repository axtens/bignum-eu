include bignum.e as B
include std/unittest.e

B:set_precision(100)

puts( 1, "add .. ")
for i = 1 to 10000 do
	integer j = i + i
	sequence bigI = B:int_to_bignum(i)
	sequence bigJ = B:add_bignum(bigI, bigI)
	-- printf( 1, "%d == %s\n", {j,B:bignum_to_string(bigJ)})
	test_equal( "n plus n", sprintf("%d", j), B:bignum_to_string(bigJ))
end for

puts( 1, "mutliply .. ")
for i = 1 to 10000 do
	integer j = i * i
	sequence bigI = B:int_to_bignum(i)
	sequence bigJ = B:multiply_bignum(bigI, bigI)
	-- printf( 1, "%d == %s\n", {j,B:bignum_to_string(bigJ)})
	test_equal( "n times n", sprintf("%d", j), B:bignum_to_string(bigJ))
end for

puts( 1, "mutliply and subtract .. ")
for i = 1 to 10000 do
	integer j = i * i - i
	sequence bigI = B:int_to_bignum(i)
	sequence bigJ = B:multiply_bignum(bigI, bigI)
	bigJ = B:subtract_bignum(bigJ, bigI)
	-- printf( 1, "%d == %s\n", {j,B:bignum_to_string(bigJ)})
	test_equal( "n times n minus n", sprintf("%d", j), B:bignum_to_string(bigJ))
end for

puts( 1, "divide .. ")
for i = 1 to 10000 do
	for j = 10000 to 1 by -1 do
		integer k = floor(i / j)
		sequence bigI = B:int_to_bignum(i)
		sequence bigJ = B:int_to_bignum(j)
		sequence bigK = B:divide_bignum(bigI, bigJ)
		test_equal( sprintf("%d divided by %d", {i,j}), sprintf("%d", k), B:bignum_to_string(bigK))
	end for 
end for

puts(1, "\n")
test_report()

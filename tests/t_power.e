include bignum.e as B
include std/unittest.e

B:set_precision(400)

function Power(integer num, integer pow)
	sequence NUM = int_to_bignum(num)
	sequence PWR = B:power_bignum(NUM,pow)
	sequence ANS = B:bignum_to_string(PWR)
	return sprintf("%s", {ANS})
end function

test_equal( "power_bignum", "21430172143725346418968500981200036211228096234110672148875007767407021022498722449863967576313917162551893458351062936503742905713846280871969155149397149607869135549648461970842149210124742283755908364306092949967163882534797535118331087892154125829142392955373084335320859663305248773674411336138752", Power(2, 1000))

test_report()

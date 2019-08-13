include std/sequence.e
include std/text.e
include std/math.e
include std/map.e
include std/get.e
with trace
trace(1)
map memo = new(1024)
-- pass by value only

constant SIGNBIT = 1
constant LASTDIGIT = 2
constant DIGITS = 3

constant PLUS = 1
constant MINUS = -1

integer precision = 100

export procedure set_precision( integer _precision = 100 )
    precision = _precision
end procedure

export function new_bignum()
    sequence bignum = {1,-1,repeat(0,precision)}
    return bignum
end function

export procedure print_bignum(sequence n) 
    if n[SIGNBIT] = MINUS then
        printf(1,"-")
    end if
    for i = n[LASTDIGIT] to 1 by -1 do
        printf(1,"%d",n[DIGITS][i])
    end for
    if n[LASTDIGIT]=0 then
        printf(1, "0")
    end if
    printf(1,"\n")
end procedure 

export function bignum_to_string( sequence b )
    integer count = b[LASTDIGIT]
    integer offset = 0
    if b[SIGNBIT] = MINUS then
        count += 1
        offset = 1
    end if
    integer j = 1
    sequence result = reverse(b[DIGITS][1..b[LASTDIGIT]])
    result = result + #30 
    if offset = 1 then
        result = "-" & result
    end if
    return result
end function 

export function int_to_bignum(integer s)       -- returns a bignum sequence
    integer t                           -- integer to work with
    
    sequence n = new_bignum()
    
    if (s >= 0) then
    n[SIGNBIT] = PLUS
    else 
    n[SIGNBIT] = MINUS
    end if
    
    n[LASTDIGIT] = 0 
    
    t = abs(s)
    
    while (t > 0) do
        n[LASTDIGIT] += 1
        n[DIGITS][n[LASTDIGIT]] = mod(t, 10)
        t = floor(t / 10)
    end while
    
    if (s = 0) then
        n[LASTDIGIT] = 1
    end if
    
    return n
end function

export function add_bignum(sequence a, sequence b) -- returning seqeunce c
	sequence key  = bignum_to_string(a) & "+" & bignum_to_string(b)
	if has(memo,key) then
		return map:get(memo,key)
	end if
	
    integer carry                       -- carry digit
    --integer i                               -- counter
    
    sequence c = new_bignum()
    
    if (a[SIGNBIT] = b[SIGNBIT]) then
        c[SIGNBIT] = a[SIGNBIT]
    else 
        if (a[SIGNBIT] = MINUS) then
            a[SIGNBIT] = PLUS
            c = subtract_bignum(b,a)
            a[SIGNBIT] = MINUS
        else 
            b[SIGNBIT] = PLUS
            c = subtract_bignum(a,b)
            b[SIGNBIT] = MINUS
        end if
        return c
    end if
    
    c[LASTDIGIT] = max({a[LASTDIGIT],b[LASTDIGIT]})
    carry = 0
    
    for i = 1 to c[LASTDIGIT] do
        c[DIGITS][i] = mod(carry + a[DIGITS][i] + b[DIGITS][i], 10)
        carry = floor((carry + a[DIGITS][i] + b[DIGITS][i]) / 10)
    end for
    
    if carry > 0 then
        c[LASTDIGIT] += 1
        c[DIGITS][c[LASTDIGIT]] = carry
    end if
    c = zero_justify(c)
	put( memo, key, c)
    return c
end function


export function subtract_bignum(sequence a, sequence b)
	sequence key  = bignum_to_string(a) & "-" & bignum_to_string(b)
	if has(memo,key) then
		return map:get(memo,key)
	end if

    integer borrow                      -- has anything been borrowed?
    integer v                           -- placeholder digit
    --integer i                               -- counter
    
    sequence c = new_bignum()
    
    if ((a[SIGNBIT] = MINUS) or (b[SIGNBIT] = MINUS)) then
        b[SIGNBIT] = -1 * b[SIGNBIT]
        c = add_bignum(a,b)
        b[SIGNBIT] = -1 * b[SIGNBIT]
        return c
    end if
    
    if (compare_bignum(a,b) = PLUS) then
        c = subtract_bignum(b,a)
        c[SIGNBIT] = MINUS
        return c
    end if
    
    c[LASTDIGIT] = max({a[LASTDIGIT],b[LASTDIGIT]})
    borrow = 0
    
    for i = 1 to c[LASTDIGIT] do
        v = (a[DIGITS][i] - borrow - b[DIGITS][i])
        if (a[DIGITS][i] > 0) then
            borrow = 0
        end if
        if (v < 0) then
            v = v + 10
            borrow = 1
        end if
        
        c[DIGITS][i] = mod(v, 10)
    end for
    
    c = zero_justify(c)
	put( memo, key, c)
    return c
end function

export function compare_bignum(sequence a, sequence b)
	sequence key  = bignum_to_string(a) & "$" & bignum_to_string(b)
	if has(memo,key) then
		return map:get(memo,key)
	end if

    integer res = 0
    if ((a[SIGNBIT] = MINUS) and (b[SIGNBIT] = PLUS)) then 
        res = PLUS 
    elsif ((a[SIGNBIT] = PLUS) and (b[SIGNBIT] = MINUS)) then 
        res = MINUS
    elsif (b[LASTDIGIT] > a[LASTDIGIT]) then 
        res = (PLUS * a[SIGNBIT]) 
    elsif (a[LASTDIGIT] > b[LASTDIGIT]) then 
        res = (MINUS * a[SIGNBIT]) 
    else
        for i = a[LASTDIGIT] to 1 by -1 do 
            if (a[DIGITS][i] > b[DIGITS][i]) then 
                res = (MINUS * a[SIGNBIT])
                break
            end if
            if (b[DIGITS][i] > a[DIGITS][i]) then 
                res = (PLUS * a[SIGNBIT])
                break
            end if
        end for
    end if
	put( memo, key, res)
    return res
end function 

function zero_justify(sequence n)
    
    while ((n[LASTDIGIT] > 1) and (n[DIGITS][ n[LASTDIGIT] ] = 0)) do
        n[LASTDIGIT] -= 1
    end while
    
    if ((n[LASTDIGIT] = 1) and (n[DIGITS][1] = 0)) then
        n[SIGNBIT] = PLUS               -- hack to avoid -0
    end if
    
    return n
end function


function digit_shift(sequence n, integer d) -- multiply n by 10^d
    --integer i                               -- counter
    
    if ((n[LASTDIGIT] = 1) and (n[DIGITS][1] = 0)) then
        return n
    end if
    
    for i = n[LASTDIGIT] to 1 by -1 do 
        n[DIGITS][i+d] = n[DIGITS][i]
    end for
    
    for i = 1 to d do 
        n[DIGITS][i] = 0
    end for
    
    n[LASTDIGIT] = n[LASTDIGIT] + d
    return n
end function



export function multiply_bignum(sequence a, sequence b)
	sequence key  = bignum_to_string(a) & "*" & bignum_to_string(b)
	if has(memo,key) then
		return map:get(memo,key)
	end if

    sequence row = int_to_bignum(0)                    -- represent shifted row
    sequence tmp = int_to_bignum(0) -- placeholder bignum
    --integer i,j                     -- counters
    
    sequence c = int_to_bignum(0)
    
    row = a
    
    for i = 1 to b[LASTDIGIT] do 
        for j = 1 to b[DIGITS][i]  do
            tmp = add_bignum(c,row)
            c = tmp
        end for
        row = digit_shift(row,1)
    end for
    
    c[SIGNBIT] = a[SIGNBIT] * b[SIGNBIT]
    
    c = zero_justify(c)
	put( memo, key, c)
    return c
end function


export function divide_bignum(sequence a, sequence b)
	sequence key  = bignum_to_string(a) & "/" & bignum_to_string(b)
	if has(memo,key) then
		return map:get(memo,key)
	end if
    
    --sequence row                        -- represent shifted row
    --sequence tmp                        -- placeholder bignum
    
    integer asign, bsign                -- temporary signs
    --integer i,j                        -- counters
    
    sequence c = int_to_bignum(0)
    
    c[SIGNBIT] = a[SIGNBIT] * b[SIGNBIT]
    
    asign = a[SIGNBIT]
    bsign = b[SIGNBIT]
    
    a[SIGNBIT] = PLUS
    b[SIGNBIT] = PLUS
    
    sequence row = int_to_bignum(0)
    sequence tmp = int_to_bignum(0)
    
    c[LASTDIGIT] = a[LASTDIGIT]
    
    for i = a[LASTDIGIT] to 1 by -1 do 
        row = digit_shift(row,1)
        row[DIGITS][1] = a[DIGITS][i]
        c[DIGITS][i] = 0
        while (compare_bignum(row,b) != PLUS) do
            c[DIGITS][i] += 1
            tmp = subtract_bignum(row,b)
            row = tmp
        end while 
    end for 
    
    c = zero_justify(c)
    
    a[SIGNBIT] = asign
    b[SIGNBIT] = bsign
	put( memo, key, c)
    return c
end function

export function power_bignum(sequence a, integer n)
	sequence key  = bignum_to_string(a) & "^" &  sprintf("%d",n)
	if has(memo,key) then
		return map:get(memo,key)
	end if
      sequence c = int_to_bignum(0)
	  
      if n = 0 then
        c = int_to_bignum(1)
      else 
		c = a
		sequence res = int_to_bignum(0)

		for i = 1 to n do
			res = multiply_bignum( a, c )
			c = res
		end for
	  end if
	put( memo, key, c)

      return c
end function

export function modulus_bignum(sequence a, sequence b)
	sequence key  = bignum_to_string(a) & "%" & bignum_to_string(b)
	if has(memo,key) then
		return map:get(memo,key)
	end if
      sequence c = int_to_bignum(0)
      integer comp = compare_bignum(a, b)
      if comp = MINUS then
        sequence div = divide_bignum(a, b)
        sequence mul = multiply_bignum(div, b)
        sequence sub = subtract_bignum(a, mul)
        c = sub
      elsif comp = PLUS then
        c = a
      else
        c = int_to_bignum(0)
      end if
	put( memo, key, c)
      return c
end function


export function base_to_bignum( sequence basedNumber, sequence dijits )
	return 1
end function

export function bignum_to_base( sequence a, sequence dijits )
	sequence base = int_to_bignum(length(dijits))
	sequence zero = int_to_bignum(0)
	sequence c = ""

	while compare_bignum(zero,a) = PLUS do
		sequence offs = modulus_bignum(base, a)
		sequence bts = bignum_to_string(offs)
		sequence valu = value(bts)
		c = dijits[valu[2]] & c
		a = divide_bignum(a, base)
	end while

	return c
end function

-- printf(1,"%s",{bignum_to_base(int_to_bignum(255),"0123456789ABCDEF")})

    -- base_to_bignum : function (based, numset) {
      -- var base = this.toBignum(numset.length);
      -- var bignum = this.toBignum(0);
      -- var c = 0;
      -- for (var i = based.length - 1, j = 0; i >= 0; i--, j++) {
        -- c = based.substr(i, 1);
        -- var pwr = this.power_bignum(base, j);
        -- var ioc = this.toBignum(numset.indexOf(c));
        -- var mul;
        -- if (this.compare_bignum(ioc, pwr) === PLUS) {
          -- mul = this.multiply_bignum(pwr, ioc);
        -- } else {
          -- mul = this.multiply_bignum(ioc, pwr);
        -- }
        -- bignum = this.add_bignum(bignum, mul);
      -- }
      -- return bignum;
    -- }

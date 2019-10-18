IN: math-contrib
USING: errors kernel sequences math sequences-internals namespaces arrays ;

: deg>rad pi * 180 / ; inline
: rad>deg 180 * pi / ; inline

: lcm ( a b -- c )
    #! Smallest integer such that c/a and c/b are both integers.
    [ * ] 2keep gcd nip /i ; foldable

: mod-inv ( x n -- y )
    #! Compute the multiplicative inverse of x mod n.
    gcd 1 = [ "Non-trivial divisor found" throw ] unless ;
    foldable

: each-bit ( n quot -- )
    over zero? pick -1 number= or [
        2drop
    ] [
        2dup >r >r >r 1 bitand r> call r> -1 shift r> each-bit
    ] if ; inline

: (^mod) ( n z w -- z^w )
    1 swap [
        1 number= [ dupd * pick mod ] when >r sq over mod r>
    ] each-bit 2nip ; inline

: ^mod ( z w n -- z^w )
    #! Compute z^w mod n.
    over 0 < [
        [ >r neg r> ^mod ] keep mod-inv
    ] [
        -rot (^mod)
    ] if ; foldable

: powers ( n x -- seq )
    #! Output sequence has n elements, { 1 x x^2 x^3 ... }
    <array> 1 [ * ] accumulate nip ;

: ** ( u v -- u*v' ) conjugate * ; inline

: c. ( v v -- x )
    #! Complex inner product.
    0 [ ** + ] 2reduce ;

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    1./0. -1./0. rot [ dup pick max -rot nip pick min -rot nip ] each ;

: absminmax ( seq -- min max )
    #! find the absolute values of the min and max of a seq in one pass
    minmax 2dup [ abs ] 2apply > [ swap ] when ;

SYMBOL: almost=-precision .000001 almost=-precision set-global

: almost= ( a b -- bool )
    - abs almost=-precision get < ;

: m-almost= ( m n -- ? )
    t -rot [ [ almost= and ] 2each ] 2each ;

TUPLE: frange from step length ;

C: frange ( from step to -- seq )
    #! example: 0 .01 10 <frange> >array
    >r pick - swap [ / ceiling 1+ >bignum ] keep r> 
    [ set-frange-step ] keep
    [ set-frange-length ] keep
    [ set-frange-from ] keep ;

: <frange-no-endpt> ( from step to -- seq )
    over - <frange> ;

M: frange length ( frange -- n ) frange-length ;
M: frange nth ( n frange -- obj ) [ frange-step * ] keep frange-from + ;

: frange-range ( frange -- range )
    [ frange-step ] keep frange-length 1- * ;

SYMBOL: step-size .01 step-size set-global  ! TODO: base on arguments
: (limit) ( count diff quot -- x quot )
    pick 10 > [ "Not converging fast enough" throw ] when
    [ call ] keep >r 2dup swap - 0 < [ "not converging" throw ] when
    2dup almost= rot drop r>
    swap [ step-size [ 2 / ] change rot 1+ -rot (limit) ] unless ;

: limit ( quot -- x )
    .1 step-size set [ call ] keep
    step-size [ 2 / ] change 0 -rot (limit) 2drop ;

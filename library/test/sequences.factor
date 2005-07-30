IN: temporary
USING: kernel lists math sequences strings test vectors ;

[ { 1 2 3 4 } ] [ 1 5 <range> >vector ] unit-test
[ 3 ] [ 1 4 <range> length ] unit-test
[ { 4 3 2 1 } ] [ 4 0 <range> >vector ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ { 2 3 } ] [ 1 3 { 1 2 3 4 } <slice> >vector ] unit-test
[ { 4 5 } ] [ 2 { 1 2 3 4 5 } tail-slice* >vector ] unit-test
[ { 1 2 } { 3 4 } ] [ 2 { 1 2 3 4 } cut ] unit-test
[ { 1 2 } { 4 5 } ] [ 2 { 1 2 3 4 5 } cut* ] unit-test
[ { 3 4 } ] [ 2 4 1 10 <range> subseq ] unit-test
[ { 3 4 } ] [ 0 2 2 4 1 10 <range> <slice> subseq ] unit-test
[ "cba" ] [ 3 "abcdef" head-slice reverse ] unit-test

[ 1 2 3 ] [ 1 2 3 3vector 3unseq ] unit-test

[ 5040 ] [ [ 1 2 3 4 5 6 7 ] 1 [ * ] reduce ] unit-test

[ [ 1 1 2 6 24 120 720 ] ]
[ [ 1 2 3 4 5 6 7 ] 1 [ * ] accumulate ] unit-test

[ -1 f ] [ [ ] [ ] find ] unit-test
[ 0 1 ] [ [ 1 ] [ ] find ] unit-test
[ 1 "world" ] [ [ "hello" "world" ] [ "world" = ] find ] unit-test
[ 2 3 ] [ [ 1 2 3 ] [ 2 > ] find ] unit-test
[ -1 f ] [ [ 1 2 3 ] [ 10 > ] find ] unit-test

[ 1 CHAR: e ]
[ "aeiou" "hello world" [ swap member? ] find-with ] unit-test

[ 4 CHAR: o ]
[ "aeiou" 3 "hello world" [ swap member? ] find-with* ] unit-test

[ f         ] [ 3 [ ]     member? ] unit-test
[ f         ] [ 3 [ 1 2 ] member? ] unit-test
[ t ] [ 1 [ 1 2 ] member? ] unit-test
[ t ] [ 2 [ 1 2 ] member? ] unit-test

[ t ]
[ [ "hello" "world" ] [ second ] keep memq? ] unit-test

[ 4 ] [ CHAR: x "tuvwxyz" >vector index ] unit-test 

[ -1 ] [ CHAR: x 5 "tuvwxyz" >vector index* ] unit-test 

[ -1 ] [ CHAR: a 0 "tuvwxyz" >vector index* ] unit-test

[ f ] [ [ "Hello" { } 4/3 ] [ string? ] all? ] unit-test
[ t ] [ [ ] [ ] all? ] unit-test
[ t ] [ [ "hi" t 1/2 ] [ ] all? ] unit-test

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] subset ] unit-test
[ { 4 2 6 } ] [ { 1 4 2 5 3 6 } [ 2 mod 0 = ] subset ] unit-test

[ [ 3 ] ] [ 2 [ 1 2 3 ] [ < ] subset-with ] unit-test

[ "hello world how are you" ]
[ { "hello" "world" "how" "are" "you" } " " join ]
unit-test

[ "" ] [ { } "" join ] unit-test

[ { "three" "three" "two" "two" "one" "one" } ]
[ { "one" "two" "three" } { 1 2 3 } { 3 3 2 2 1 1 } subst ]
unit-test

[ { 1 2 }   ] [ 1 2   2vector ] unit-test
[ { 1 2 3 } ] [ 1 2 3 3vector ] unit-test

[ { } ] [ { } flip ] unit-test

[ { "b" "e" } ] [ 1 { { "a" "b" "c" } { "d" "e" "f" } } <column> >vector ] unit-test

[ { { 1 4 } { 2 5 } { 3 6 } } ]
[ { { 1 2 3 } { 4 5 6 } } flip ] unit-test

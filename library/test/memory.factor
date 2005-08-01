IN: temporary
USING: generic kernel lists math memory words prettyprint 
sequences test ;

TUPLE: testing x y z ;

[ f 1 2 3 ] [ 1 2 3 <testing> [ ] each-slot ] unit-test

[ ] [
    num-types [
        builtin-type [
            dup \ cons = [
                ! too many conses!
                drop
            ] [
                "predicate" word-prop instances [
                    class drop
                ] each
            ] ifte
        ] when*
    ] each
] unit-test

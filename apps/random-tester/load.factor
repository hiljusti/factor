REQUIRES: libs/lazy-lists libs/null-stream libs/shuffle ;
PROVIDE: apps/random-tester
{ +files+ {
    "safe.factor"
    "utils.factor"
    "random.factor"
    "random-tester.factor"
    "random-tester2.factor"
    "type.factor"
} } ;

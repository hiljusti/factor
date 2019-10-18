IN: scratchpad
USE: parser
USE: stdio
USE: test
USE: unparser

"Reader tests" print

![ [ one [ two [ three ] four ] five ] ]
![ "one [ two [ three ] four ] five" ]
![ parse ]
!test-word

[ [ 1 [ 2 [ 3 ] 4 ] 5 ] ]
[ "1\n[\n2\n[\n3\n]\n4\n]\n5" ]
[ parse ]
test-word

[ [ t t f f ] ]
[ "t t f f" ]
[ parse ]
test-word

![ [ "hello world" ] ]
![ "\"hello world\"" ]
![ parse ]
!test-word

[ [ "\n\r\t\\" ] ]
[ "\"\\n\\r\\t\\\\\"" ]
[ parse ]
test-word

![ [ "hello\nworld" x y z ] ]
![ "\"hello\\nworld\" x y z" ]
![ parse ]
!test-word

[ "hello world" ]
[ "IN: scratchpad : hello \"hello world\" ;" ]
[ parse call "USE: scratchpad hello" eval ]
test-word

[ 1 2 ]
[ "IN: scratchpad ~<< my-swap a b -- b a >>~" ]
[ parse call 2 1 "USE: scratchpad my-swap" eval ]
test-word

[ ]
[ "! This is a comment, people." ]
[ parse call ]
test-word

[ ]
[ "( This is a comment, people. )" ]
[ parse call ]
test-word

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" ]
[ unparse ]
test-word

! Make sure parseObject() preserves doc comments.
[ "( this is a comment )\n" ]
[ "( this is a comment )" ]
[
    interpreter
    [ "java.lang.String" "factor.FactorInterpreter" ]
    "factor.FactorReader" "parseObject"
    jinvoke-static
    unparse
] test-word

! Test escapes

[ [ " " ] ]
[ "\"\\u0020\"" ]
[ parse ]
test-word

[ [ "'" ] ]
[ "\"\\u0027\"" ]
[ parse ]
test-word

[ "\"\\u1234\"" ]
[ "\u1234" ]
[ unparse ]
test-word

[ "\"\\e\"" ]
[ "\e" ]
[ unparse ]
test-word

"Reader tests done" print
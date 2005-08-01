! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: alien assembler compiler errors files generic generic
hashtables hashtables io io-internals kernel kernel
kernel-internals lists lists math math math-internals memory
namespaces parser parser profiler sequences strings unparser
vectors vectors words words ;

"Creating primitives and basic runtime structures..." print

! This symbol needs the same hashcode in the target as in the
! host.
vocabularies

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab clone
"generic" vocab clone

<namespace> vocabularies set
<namespace> typemap set
num-types empty-vector builtins set
<namespace> crossref set

vocabularies get [
    "generic" set
    "syntax" set
    reveal
] bind

: set-stack-effect ( { vocab word effect } -- )
    3unseq >r unit search r> dup string? [
        "stack-effect" set-word-prop
    ] [
        "infer-effect" set-word-prop
    ] ifte ;

: make-primitive ( { vocab word effect } n -- )
    >r dup 2unseq create r> f define set-stack-effect ;

{
    { "execute" "words"                       [ [ word ] [ ] ] }
    { "call" "kernel"                         [ [ general-list ] [ ] ] }
    { "ifte" "kernel"                         [ [ object general-list general-list ] [ ] ] }
    { "dispatch" "kernel-internals"           [ [ fixnum vector ] [ ] ] }
    { "cons" "lists"                          [ [ object object ] [ cons ] ] }
    { "<vector>" "vectors"                    [ [ integer ] [ vector ] ] }
    { "rehash-string" "strings"               [ [ string ] [ ] ] }
    { "<sbuf>" "strings"                      [ [ integer ] [ sbuf ] ] }
    { "sbuf>string" "strings"                 [ [ sbuf ] [ string ] ] }
    { "arithmetic-type" "math-internals"      [ [ object object ] [ object object fixnum ] ] }
    { ">fixnum" "math"                        [ [ number ] [ fixnum ] ] }
    { ">bignum" "math"                        [ [ number ] [ bignum ] ] }
    { ">float" "math"                         [ [ number ] [ float ] ] }
    { "(fraction>)" "math-internals"          [ [ integer integer ] [ rational ] ] }
    { "str>float" "parser"                    [ [ string ] [ float ] ] }
    { "(unparse-float)" "unparser"            [ [ float ] [ string ] ] }
    { "float>bits" "math"                     [ [ real ] [ integer ] ] }
    { "double>bits" "math"                    [ [ real ] [ integer ] ] }
    { "bits>float" "math"                     [ [ integer ] [ float ] ] }
    { "bits>double" "math"                    [ [ integer ] [ float ] ] }
    { "<complex>" "math-internals"            [ [ real real ] [ number ] ] }
    { "fixnum+" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum-" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum*" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum/i" "math-internals"             [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum/f" "math-internals"             [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum-mod" "math-internals"           [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum/mod" "math-internals"           [ [ fixnum fixnum ] [ integer fixnum ] ] }
    { "fixnum-bitand" "math-internals"        [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum-bitor" "math-internals"         [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum-bitxor" "math-internals"        [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum-bitnot" "math-internals"        [ [ fixnum ] [ fixnum ] ] }
    { "fixnum-shift" "math-internals"         [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum<" "math-internals"              [ [ fixnum fixnum ] [ boolean ] ] }
    { "fixnum<=" "math-internals"             [ [ fixnum fixnum ] [ boolean ] ] }
    { "fixnum>" "math-internals"              [ [ fixnum fixnum ] [ boolean ] ] }
    { "fixnum>=" "math-internals"             [ [ fixnum fixnum ] [ boolean ] ] }
    { "bignum=" "math-internals"              [ [ bignum bignum ] [ boolean ] ] }
    { "bignum+" "math-internals"              [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-" "math-internals"              [ [ bignum bignum ] [ bignum ] ] }
    { "bignum*" "math-internals"              [ [ bignum bignum ] [ bignum ] ] }
    { "bignum/i" "math-internals"             [ [ bignum bignum ] [ bignum ] ] }
    { "bignum/f" "math-internals"             [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-mod" "math-internals"           [ [ bignum bignum ] [ bignum ] ] }
    { "bignum/mod" "math-internals"           [ [ bignum bignum ] [ bignum bignum ] ] }
    { "bignum-bitand" "math-internals"        [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-bitor" "math-internals"         [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-bitxor" "math-internals"        [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-bitnot" "math-internals"        [ [ bignum ] [ bignum ] ] }
    { "bignum-shift" "math-internals"         [ [ bignum bignum ] [ bignum ] ] }
    { "bignum<" "math-internals"              [ [ bignum bignum ] [ boolean ] ] }
    { "bignum<=" "math-internals"             [ [ bignum bignum ] [ boolean ] ] }
    { "bignum>" "math-internals"              [ [ bignum bignum ] [ boolean ] ] }
    { "bignum>=" "math-internals"             [ [ bignum bignum ] [ boolean ] ] }
    { "float=" "math-internals"               [ [ bignum bignum ] [ boolean ] ] }
    { "float+" "math-internals"               [ [ float float ] [ float ] ] }
    { "float-" "math-internals"               [ [ float float ] [ float ] ] }
    { "float*" "math-internals"               [ [ float float ] [ float ] ] }
    { "float/f" "math-internals"              [ [ float float ] [ float ] ] }
    { "float<" "math-internals"               [ [ float float ] [ boolean ] ] }
    { "float<=" "math-internals"              [ [ float float ] [ boolean ] ] }
    { "float>" "math-internals"               [ [ float float ] [ boolean ] ] }
    { "float>=" "math-internals"              [ [ float float ] [ boolean ] ] }
    { "facos" "math-internals"                [ [ real ] [ float ] ] }
    { "fasin" "math-internals"                [ [ real ] [ float ] ] }
    { "fatan" "math-internals"                [ [ real ] [ float ] ] }
    { "fatan2" "math-internals"               [ [ real real ] [ float ] ] }
    { "fcos" "math-internals"                 [ [ real ] [ float ] ] }
    { "fexp" "math-internals"                 [ [ real ] [ float ] ] }
    { "fcosh" "math-internals"                [ [ real ] [ float ] ] }
    { "flog" "math-internals"                 [ [ real ] [ float ] ] }
    { "fpow" "math-internals"                 [ [ real real ] [ float ] ] }
    { "fsin" "math-internals"                 [ [ real ] [ float ] ] }
    { "fsinh" "math-internals"                [ [ real ] [ float ] ] }
    { "fsqrt" "math-internals"                [ [ real ] [ float ] ] }
    { "<word>" "words"                        [ [ ] [ word ] ] }
    { "update-xt" "words"                     [ [ word ] [ ] ] }
    { "compiled?" "words"                     [ [ word ] [ boolean ] ] }
    { "drop" "kernel"                         [ [ object ] [ ] ] }
    { "dup" "kernel"                          [ [ object ] [ object object ] ] }
    { "swap" "kernel"                         [ [ object object ] [ object object ] ] }
    { "over" "kernel"                         [ [ object object ] [ object object object ] ] }
    { "pick" "kernel"                         [ [ object object object ] [ object object object object ] ] }
    { ">r" "kernel"                           [ [ object ] [ ] ] }
    { "r>" "kernel"                           [ [ ] [ object ] ] }
    { "eq?" "kernel"                          [ [ object object ] [ boolean ] ] }
    { "getenv" "kernel-internals"             [ [ fixnum ] [ object ] ] }
    { "setenv" "kernel-internals"             [ [ object fixnum ] [ ] ] }
    { "stat" "io"                             [ [ string ] [ general-list ] ] }
    { "(directory)" "io"                      [ [ string ] [ general-list ] ] }
    { "gc" "memory"                           [ [ fixnum ] [ ] ] }
    { "gc-time" "memory"                      [ [ string ] [ ] ] }
    { "save-image" "memory"                   [ [ string ] [ ] ] }
    { "datastack" "kernel"                    " -- ds "          }
    { "callstack" "kernel"                    " -- cs "          }
    { "set-datastack" "kernel"                " ds -- "          }
    { "set-callstack" "kernel"                " cs -- "          }
    { "exit" "kernel"                         [ [ integer ] [ ] ] }
    { "room" "memory"                         [ [ ] [ integer integer integer integer general-list ] ] }
    { "os-env" "kernel"                       [ [ string ] [ object ] ] }
    { "millis" "kernel"                       [ [ ] [ integer ] ] }
    { "(random-int)" "math"                   [ [ ] [ integer ] ] }
    { "type" "kernel"                         [ [ object ] [ fixnum ] ] }
    { "cwd" "io"                              [ [ ] [ string ] ] }
    { "cd" "io"                               [ [ string ] [ ] ] }
    { "compiled-offset" "assembler"           [ [ ] [ integer ] ] }
    { "set-compiled-offset" "assembler"       [ [ integer ] [ ] ] }
    { "literal-top" "assembler"               [ [ ] [ integer ] ] }
    { "set-literal-top" "assembler"           [ [ integer ] [ ] ] }
    { "address" "memory"                      [ [ object ] [ integer ] ] }
    { "dlopen" "alien"                        [ [ string ] [ dll ] ] }
    { "dlsym" "alien"                         [ [ string object ] [ integer ] ] }
    { "dlclose" "alien"                       [ [ dll ] [ ] ] }
    { "<alien>" "alien"                       [ [ integer ] [ alien ] ] }
    { "<byte-array>" "kernel-internals"       [ [ integer ] [ byte-array ] ] }
    { "<displaced-alien>" "alien"             [ [ integer c-ptr ] [ displaced-alien ] ] }
    { "alien-signed-cell" "alien"             [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-cell" "alien"         [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-cell" "alien"           [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-cell" "alien"       [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-8" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-8" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-8" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-8" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-4" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-4" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-4" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-4" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-2" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-2" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-2" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-2" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-1" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-1" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-1" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-1" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-float" "alien"                   [ [ c-ptr integer ] [ float ] ] }
    { "set-alien-float" "alien"               [ [ float c-ptr integer ] [ ] ] }
    { "alien-double" "alien"                  [ [ c-ptr integer ] [ float ] ] }
    { "set-alien-double" "alien"              [ [ float c-ptr integer ] [ ] ] }
    { "alien-c-string" "alien"                [ [ c-ptr integer ] [ string ] ] }
    { "set-alien-c-string" "alien"            [ [ string c-ptr integer ] [ ] ] }
    { "throw" "errors"                        [ [ object ] [ ] ] }
    { "string>memory" "kernel-internals"      [ [ string integer ] [ ] ] }
    { "memory>string" "kernel-internals"      [ [ integer integer ] [ string ] ] }
    { "alien-address" "alien"                 [ [ alien ] [ integer ] ] }
    { "slot" "kernel-internals"               [ [ object fixnum ] [ object ] ] }
    { "set-slot" "kernel-internals"           [ [ object object fixnum ] [ ] ] }
    { "integer-slot" "kernel-internals"       [ [ object fixnum ] [ integer ] ] }
    { "set-integer-slot" "kernel-internals"   [ [ integer object fixnum ] [ ] ] }
    { "char-slot" "kernel-internals"          [ [ object fixnum ] [ fixnum ] ] }
    { "set-char-slot" "kernel-internals"      [ [ integer object fixnum ] [ ] ] }
    { "resize-array" "kernel-internals"       [ [ integer array ] [ array ] ] }
    { "resize-string" "strings"               [ [ integer string ] [ string ] ] }
    { "<hashtable>" "hashtables"              [ [ number ] [ hashtable ] ] }
    { "<array>" "kernel-internals"            [ [ number ] [ array ] ] }
    { "<tuple>" "kernel-internals"            [ [ number ] [ tuple ] ] }
    { "begin-scan" "memory"                   [ [ ] [ ] ] }
    { "next-object" "memory"                  [ [ ] [ object ] ] }
    { "end-scan" "memory"                     [ [ ] [ ] ] }
    { "size" "memory"                         [ [ object ] [ fixnum ] ] }
    { "die" "kernel"                          [ [ ] [ ] ] }
    { "flush-icache" "assembler"              f }
    [ "fopen"  "io-internals"                 [ [ string string ] [ alien ] ] ]
    { "fgetc" "io-internals"                  [ [ alien ] [ object ] ] }
    { "fwrite" "io-internals"                 [ [ string alien ] [ ] ] }
    { "fflush" "io-internals"                 [ [ alien ] [ ] ] }
    { "fclose" "io-internals"                 [ [ alien ] [ ] ] }
    { "expired?" "alien"                      [ [ object ] [ boolean ] ] }
} dup length 3 swap [ + ] map-with [
    make-primitive
] 2each

! These need a more descriptive comment.
{
    { "drop" "kernel" " x -- " }
    { "dup" "kernel"  " x -- x x " }
    { "swap" "kernel" " x y -- y x " }
    { "over" "kernel" " x y -- x y x " }
    { "pick" "kernel" " x y z -- x y z x " }
    { ">r" "kernel"   " x -- r: x " }
    { "r>" "kernel"   " r: x -- x " }
} [
    set-stack-effect
] each

FORGET: make-primitive
FORGET: set-stack-effect

! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: parser
USE: arithmetic
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: strings
USE: words
USE: unparser

! Number parsing

: not-a-number "Not a number" throw ;

: digit> ( ch -- n )
    [
        [ digit? ] [ CHAR: 0 - ]
        [ letter? ] [ CHAR: a - 10 + ]
        [ LETTER? ] [ CHAR: A - 10 + ]
        [ drop t ] [ not-a-number ]
    ] cond ;

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] ifte ;

: digit ( num digit -- num )
    "base" get swap 2dup > [
        >r * r> +
    ] [
        not-a-number
    ] ifte ;

: (str>integer) ( str -- num )
    dup str-length 0 = [
        not-a-number
    ] [
        0 swap [ digit> digit ] str-each
    ] ifte ;

: str>integer ( str -- num )
    #! Parse a string representation of an integer.
    dup str-length 0 = [
        drop not-a-number
    ] [
        dup "-" str-head? dup [
            nip (str>integer) neg
        ] [
            drop (str>integer)
        ] ifte
    ] ifte ;

: str>ratio ( str -- num )
    dup CHAR: / index-of str//
    swap str>integer swap str>integer / ;

: str>number ( str -- num )
    #! Affected by "base" variable.
    [
        [ "/" swap str-contains? ] [ str>ratio   ]
        [ "." swap str-contains? ] [ str>float   ]
        [ drop t                 ] [ str>integer ]
    ] cond ;

: base> ( str base -- num/f )
    [
        "base" set
        [ str>number ] [ [ drop f ] when ] catch
    ] with-scope ;

: bin> ( str -- num )
    #! Convert a binary string to a number.
    2 base> ;

: oct> ( str -- num )
    #! Convert an octal string to a number.
    8 base> ;

: dec> ( str -- num )
    #! Convert a decimal string to a number.
    10 base> ;

: hex> ( str -- num )
    #! Convert a hexadecimal string to a number.
    16 base> ;

! Something really sucks about these words here
: parse-number ( str -- num ) dec> ;

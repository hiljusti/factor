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
USE: vocabularies
USE: unparser

! Parsing words. 'builtins' is a stupid vocabulary name now
! that it does not contain Java words anymore!

IN: builtins

! Constants
: t t parsed ; parsing
: f f parsed ; parsing

! Lists
: [ f ; parsing
: ] nreverse parsed ; parsing

: | ( syntax: | cdr ] )
    #! See the word 'parsed'. We push a special sentinel, and
    #! 'parsed' acts accordingly.
    "|" ; parsing

! Colon defs
: :
    #! Begin a word definition. Word name follows.
    scan "in" get create f ; parsing

: ;
    #! End a word definition.
    nreverse define ; parsing

! Vocabularies
: DEFER: scan "in" get create drop ; parsing
: USE: scan "use" cons@ ; parsing
: IN: scan dup "use" cons@ "in" set ; parsing

! \x
: escape ( ch -- esc )
    [
        [ CHAR: e | CHAR: \e ]
        [ CHAR: n | CHAR: \n ]
        [ CHAR: r | CHAR: \r ]
        [ CHAR: t | CHAR: \t ]
        [ CHAR: s | CHAR: \s ]
        [ CHAR: \s | CHAR: \s ]
        [ CHAR: 0 | CHAR: \0 ]
        [ CHAR: \\ | CHAR: \\ ]
        [ CHAR: \" | CHAR: \" ]
    ] assoc ;

! String literal

: parse-escape ( -- )
    next-ch escape dup [ drop "Bad escape" throw ] unless ;

: parse-ch ( ch -- ch )
    dup CHAR: \\ = [ drop parse-escape ] when ;

: parse-string ( -- )
    next-ch dup CHAR: " = [
        drop
    ] [
        parse-ch % parse-string
    ] ifte ;

: "
    #! Note the ugly hack to carry the new value of 'pos' from
    #! the <% %> scope up to the original scope.
    <% parse-string "pos" get %> swap "pos" set parsed ; parsing

! Char literal
: CHAR: ( -- ) skip-blank next-ch parse-ch parsed ; parsing

! Comments
: ( ")" until drop ; parsing
: ! until-eol drop ; parsing
: #! until-eol drop ; parsing
    
! Reading numbers in other bases

: BASE: ( base -- )
    #! Read a number in a specific base.
    "base" get >r "base" set scan number, r> "base" set ;

: HEX: 16 BASE: ; parsing
: DEC: 10 BASE: ; parsing
: OCT: 8 BASE: ; parsing
: BIN: 2 BASE: ; parsing
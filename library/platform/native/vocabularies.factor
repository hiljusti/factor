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

IN: vocabularies
USE: lists
USE: namespaces
USE: stack
USE: words

: (search) ( name vocab -- word )
    vocab dup [ get* ] [ 2drop f ] ifte ;

: search ( name list -- word )
    #! Search for a word in a list of vocabularies.
    dup [
        2dup car (search) dup [
            nip nip ( found )
        ] [
            drop cdr search ( check next )
        ] ifte
    ] [
        2drop f ( not found )
    ] ifte ;

: create-plist ( name vocab -- plist )
    "vocabulary" swons swap "name" swons 2list ;

: (undefined)
    #! Primitive# of undefined words.
    0 ;

: (create) ( name vocab -- word )
    (undefined) f 2swap create-plist <word> ;

: word+ ( name vocab word -- )
    swap vocab* put* ;

: create ( name vocab -- word )
    #! Create a new word in a vocabulary. If the vocabulary
    #! already contains the word, the existing instance is
    #! returned.
    2dup (search) dup [
        nip nip
    ] [
        drop 2dup (create) dup >r word+ r>
    ] ifte ;
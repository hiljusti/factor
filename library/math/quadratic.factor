! :folding=indent:collapseFolds=0:

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

IN: math
USE: arithmetic
USE: combinators
USE: stack

: quadratic-complete ( a b c -- a b c a b )
    [ 2dup ] dip -rot ;

: quadratic-d ( c a b -- sqrt[b^2 - 4*a*c] )
    sq -rot 4 * * - sqrt ;

: quadratic-root ( x y -- -y/x/2 )
    neg swap / 2 / ;

: quadratic-roots ( a b d -- alpha beta )
    3dup - quadratic-root [ + quadratic-root ] dip ;

: quadratic ( a b c -- alpha beta )
    #! Finds both roots of the polynomial a*x^2 + b*x + c using
    #! the quadratic formula.
    quadratic-complete quadratic-d quadratic-roots ;
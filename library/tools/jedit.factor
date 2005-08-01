! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: jedit
USING: kernel lists namespaces parser sequences io strings
unparser words ;

! Some words to send requests to a running jEdit instance to
! edit files and position the cursor on a specific line number.

: jedit-server-file ( -- path )
    "jedit-server-file" get
    [ "~" get "/.jedit/server" append ] unless* ;

: jedit-server-info ( -- port auth )
    jedit-server-file <file-reader> [
        readln drop
        readln str>number
        readln str>number
    ] with-stream ;

: make-jedit-request ( files params -- code )
    [
        "EditServer.handleClient(false,false,false,null," %
        "new String[] {" %
        [ unparse % "," % ] each
        "null});\n" %
    ] make-string ;

: send-jedit-request ( request -- )
    jedit-server-info swap "localhost" swap <client> [
        4 >be write
        dup length 2 >be write
        write flush
    ] with-stream ;

: jedit-line/file ( file line -- )
    unparse "+line:" swap append 2list
    make-jedit-request send-jedit-request ;

: jedit-file ( file -- )
    unit make-jedit-request send-jedit-request ;

: jedit ( word -- )
    #! Note that line numbers here start from 1
    dup word-file dup [
        swap "line" word-prop jedit-line/file
    ] [
        2drop "Unknown source" print
    ] ifte ;

! Wire protocol for jEdit to evaluate Factor code.
! Packets are of the form:
!
! 4 bytes length
! <n> bytes data
!
! jEdit sends a packet with code to eval, it receives the output
! captured with string-out.

: write-len ( seq -- ) length 4 >be write ;

: write-packet ( string -- ) dup write-len write flush ;

: read-packet ( -- string ) 4 read be> read ;

: wire-server ( -- )
    #! Repeatedly read jEdit requests and execute them. Return
    #! on EOF.
    read-packet [ eval>string write-packet wire-server ] when* ;

: jedit-lookup ( word -- list )
    #! A utility word called by the Factor plugin to get some
    #! required word info.
    dup [
        [
            "vocabulary"
            "name"
            "stack-effect"
        ] [
            dupd word-prop
        ] map >r definer r> cons
    ] when ;

: completions ( str pred -- list | pred: str word -- ? )
    #! Make a list of completions. Each element of the list is
    #! a vocabulary/name/stack-effect triplet list.
    word-subset-with [ jedit-lookup ] map ;

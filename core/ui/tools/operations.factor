! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: definitions gadgets gadgets-browser gadgets-help
gadgets-listener gadgets-search gadgets-text gadgets-interactor
gadgets-workspace hashtables help inference kernel namespaces
parser prettyprint scratchpad sequences strings styles syntax
test tools words generic models io modules errors ;

V{ } clone operations set-global

SYMBOL: +name+
SYMBOL: +quot+
SYMBOL: +listener+
SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

: (command) ( -- command )
    +name+ get +keyboard+ get +quot+ get <command> ;

C: operation ( predicate hash -- operation )
    swap [
        (command) over set-delegate
        +primary+ get over set-operation-primary?
        +secondary+ get over set-operation-secondary?
        +listener+ get over set-operation-listener?
    ] bind
    [ set-operation-predicate ] keep ;

M: operation invoke-command
    [ operation-hook call ] keep
    dup command-quot swap operation-listener?
    [ curry call-listener ] [ call ] if ;

: define-operation ( class props -- )
    <operation> operations get push ;

: modify-command ( quot command -- command )
    clone
    [ command-quot append ] keep
    [ set-command-quot ] keep ;

: modify-commands ( commands quot -- commands )
    swap [ modify-command ] map-with ;

: listener-operation ( hook quot operation -- operation )
    modify-command
    tuck set-operation-hook
    t over set-operation-listener? ;

: listener-operations ( operations hook quot -- operations )
    rot [ >r 2dup r> listener-operation ] map 2nip ;

! Objects
[ drop t ] H{
    { +primary+ t }
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

[ drop t ] H{
    { +name+ "Prettyprint" }
    { +quot+ [ . ] }
    { +listener+ t }
} define-operation

[ drop t ] H{
    { +name+ "Push" }
    { +quot+ [ ] }
    { +listener+ t }
} define-operation

[ drop t ] H{
    { +name+ "Edit object" }
    { +quot+ [ unparse <input> listener-gadget call-tool ] }
} define-operation

! Input
[ input? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Input" }
    { +quot+ [ listener-gadget call-tool ] }
} define-operation

! Restart
[ restart? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Restart" }
    { +quot+ [ restart ] }
    { +listener+ t }
} define-operation

! Pathnames
[ pathname? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Edit" }
    { +quot+ [ pathname-string edit-file ] }
} define-operation

[ pathname? ] H{
    { +name+ "Run file" }
    { +keyboard+ T{ key-down f { A+ } "r" } }
    { +quot+ [ pathname-string run-file ] }
    { +listener+ t }
} define-operation

: definition-operations ( pred -- )
    {
        H{
            { +primary+ t }
            { +name+ "Browse" }
            { +keyboard+ T{ key-down f { A+ } "b" } }
            { +quot+ [ browser call-tool ] }
        } H{
            { +name+ "Edit" }
            { +keyboard+ T{ key-down f { A+ } "e" } }
            { +quot+ [ edit ] }
        } H{
            { +name+ "Reload" }
            { +keyboard+ T{ key-down f { A+ } "r" } }
            { +quot+ [ reload ] }
            { +listener+ t }
        } H{
            { +name+ "Forget" }
            { +quot+ [ forget ] }
        }
    } [ define-operation ] each-with ;

! Words
[ word? ] definition-operations

: word-completion-string ( word listener -- string )
    >r dup word-name swap word-vocabulary dup vocab r>
    listener-gadget-input interactor-use memq?
    [ drop ] [ [ "USE: " % % " " % % ] "" make ] if ;

: insert-word ( word -- )
    get-listener [ word-completion-string ] keep
    listener-gadget-input user-input ;

[ word? ] H{
    { +secondary+ t }
    { +name+ "Insert" }
    { +quot+ [ insert-word ] }
} define-operation

[ word? ] H{
    { +name+ "Documentation" }
    { +keyboard+ T{ key-down f { A+ } "h" } }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ word? ] H{
    { +name+ "Usage" }
    { +keyboard+ T{ key-down f { A+ } "u" } }
    { +quot+ [ usage. ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +name+ "Watch" }
    { +quot+ [ watch ] }
} define-operation

[ compound? ] H{
    { +name+ "Word stack effect" }
    { +quot+ [ word-def infer. ] }
    { +listener+ t }
} define-operation

! Methods
[ method-spec? ] definition-operations

! Vocabularies
[ vocab-link? ] H{
    { +primary+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ vocab-link-name get-workspace swap show-vocab-words ] }
} define-operation

[ vocab-link? ] H{
    { +name+ "Enter in" }
    { +keyboard+ T{ key-down f { A+ } "i" } }
    { +quot+ [ vocab-link-name set-in ] }
    { +listener+ t }
} define-operation

[ vocab-link? ] H{
    { +secondary+ t }
    { +name+ "Use" }
    { +quot+ [ vocab-link-name use+ ] }
    { +listener+ t }
} define-operation

[ vocab-link? ] H{
    { +name+ "Forget" }
    { +quot+ [ vocab-link-name forget-vocab ] }
} define-operation

! Modules
[ module? ] H{
    { +secondary+ t }
    { +name+ "Run" }
    { +quot+ [ module-name run-module ] }
    { +listener+ t }
} define-operation

[ module? ] H{
    { +name+ "Load" }
    { +quot+ [ module-name require ] }
    { +listener+ t }
} define-operation

[ module? ] H{
    { +name+ "Documentation" }
    { +keyboard+ T{ key-down f { A+ } "h" } }
    { +quot+ [ module-help [ help-gadget call-tool ] when* ] }
} define-operation

[ module? ] H{
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

: browse-module ( module -- )
    get-workspace swap show-module-files ;

[ module? ] H{
    { +primary+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ browse-module ] }
} define-operation

[ module? ] H{
    { +name+ "See" }
    { +quot+ [ browser call-tool ] }
} define-operation

[ module? ] H{
    { +name+ "Test" }
    { +quot+ [ module-name test-module ] }
    { +keyboard+ T{ key-down f { A+ } "t" } }
    { +listener+ t }
} define-operation

! Module links
[ module-link? ] H{
    { +secondary+ t }
    { +name+ "Run" }
    { +quot+ [ module-name run-module ] }
    { +listener+ t }
} define-operation

[ module-link? ] H{
    { +name+ "Load" }
    { +quot+ [ module-name require ] }
    { +listener+ t }
} define-operation

[ module-link? ] H{
    { +primary+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ module-name dup require module browse-module ] }
    { +listener+ t }
} define-operation

! Link
[ link? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Follow" }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ link? ] H{
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ link? ] H{
    { +name+ "Reload" }
    { +keyboard+ T{ key-down f { A+ } "r" } }
    { +quot+ [ reload ] }
} define-operation

[ word-link? ] H{
    { +name+ "Definition" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ link-name browser call-tool ] }
} define-operation

! Quotations
[ quotation? ] H{
    { +name+ "Quotation stack effect" }
    { +keyboard+ T{ key-down f { C+ } "i" } }
    { +quot+ [ infer. ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Walk" }
    { +keyboard+ T{ key-down f { C+ } "w" } }
    { +quot+ [ walk ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Time" }
    { +keyboard+ T{ key-down f { C+ } "t" } }
    { +quot+ [ time ] }
    { +listener+ t }
} define-operation

! Define commands in terms of operations

! Interactor commands
: quot-action ( interactor -- quot )
    dup editor-string swap
    2dup add-interactor-history
    select-all ;

interactor "words"
{ word compound } [ class-operations ] map concat
[ selected-word ] [ search ] listener-operations
define-commands

interactor "quotations"
quotation class-operations
[ quot-action ] [ parse ] listener-operations
define-commands

help-gadget "toolbar" {
    { "Back" T{ key-down f { C+ } "b" } [ help-gadget-history go-back ] }
    { "Forward" T{ key-down f { C+ } "f" } [ help-gadget-history go-forward ] }
    { "Home" T{ key-down f { C+ } "1" } [ go-home ] }
}
link class-operations [ help-action ] modify-commands
[ command-name "Follow" = not ] subset
append
define-commands

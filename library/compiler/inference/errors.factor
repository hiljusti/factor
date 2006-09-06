IN: inference
USING: kernel generic errors sequences prettyprint io words ;

M: inference-error error.
    dup delegate error.
    "Nesting: " write
    inference-error-rstate [ first ] map . ;

M: inference-error error-help drop f ;

M: unbalanced-branches-error error.
    "Unbalanced branches:" print
    dup unbalanced-branches-error-out
    swap unbalanced-branches-error-in
    [ pprint bl length . ] 2each ;

M: literal-expected summary
    drop "Literal value expected" ;

M: check-retain summary
    drop
    "Quotation leaves elements behind on retain stack" ;

M: no-effect error.
    "The word " write
    no-effect-word pprint
    " does not have a stack effect" print ;

M: recursive-declare-error error.
    "The recursive word " write
    recursive-declare-error-word pprint
    " must declare a stack effect" print ;

M: effect-error error.
    "Stack effects of the word " write
    dup effect-error-word pprint
    " do not match." print
    "Declared: " write
    dup effect-error-word stack-effect effect>string .
    "Inferred: " write effect-error-effect effect>string . ;

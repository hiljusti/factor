USING: alien.syntax classes.struct gdk.ffi kernel system tools.test
ui.backend.gtk ui.gestures ;
in: ui.backend.gtk.tests

: gdk-key-release-event ( -- event )
    S{ GdkEventKey
       { type 9 }
       { window alien: 1672900 }
       { send_event 0 }
       { time 1332590199 }
       { state 17 }
       { keyval 72 }
       { length 1 }
       { string alien: 1b25c80 }
       { hardware_keycode 43 }
       { group 0 }
       { is_modifier 0 }
    } ;

: gdk-key-press-event ( -- event )
    S{ GdkEventKey
       { type 8 }
       { window alien: 16727e0 }
       { send_event 0 }
       { time 1332864912 }
       { state 16 }
       { keyval 65471 }
       { length 0 }
       { string alien: 19c9700 }
       { hardware_keycode 68 }
       { group 0 }
       { is_modifier 0 }
    } ;

: gdk-space-key-press-event ( -- event )
    S{ GdkEventKey
       { type 8 }
       { window alien: 1b66360 }
       { send_event 0 }
       { time 28246628 }
       { state 0 }
       { keyval 32 }
       { length 0 }
       { string alien: 20233b0 }
       { hardware_keycode 64 }
       { group 0 }
       { is_modifier 1 }
    } ;

! The Mac build servers doesn't have the gtk libs
os linux? [
    {
        T{ key-down f f "F2" }
        T{ key-up f f "H" }
        T{ key-down f f " " }
    } [
        gdk-key-press-event key-event>gesture
        gdk-key-release-event key-event>gesture
        gdk-space-key-press-event key-event>gesture
    ] unit-test
] when
USING: http tools.test multiline tuple-syntax
io.streams.string kernel arrays splitting sequences
assocs io.sockets db db.sqlite continuations ;
IN: http.tests

[ "hello%20world" ] [ "hello world" url-encode ] unit-test
[ "hello world" ] [ "hello%20world" url-decode ] unit-test
[ "~hello world" ] [ "%7ehello+world" url-decode ] unit-test
[ f ] [ "%XX%XX%XX" url-decode ] unit-test
[ f ] [ "%XX%XX%X" url-decode ] unit-test

[ "hello world"   ] [ "hello+world"    url-decode ] unit-test
[ "hello world"   ] [ "hello%20world"  url-decode ] unit-test
[ " ! "           ] [ "%20%21%20"      url-decode ] unit-test
[ "hello world"   ] [ "hello world%"   url-decode ] unit-test
[ "hello world"   ] [ "hello world%x"  url-decode ] unit-test
[ "hello%20world" ] [ "hello world"    url-encode ] unit-test
[ "%20%21%20"     ] [ " ! "            url-encode ] unit-test

[ "\u001234hi\u002045" ] [ "\u001234hi\u002045" url-encode url-decode ] unit-test

[ "/" ] [ "http://foo.com" url>path ] unit-test
[ "/" ] [ "http://foo.com/" url>path ] unit-test
[ "/bar" ] [ "http://foo.com/bar" url>path ] unit-test
[ "/bar" ] [ "/bar" url>path ] unit-test

[ "a=b&a=c" ] [ { { "a" { "b" "c" } } } assoc>query ] unit-test

[ H{ { "a" "b" } } ] [ "a=b" query>assoc ] unit-test

[ H{ { "a" { "b" "c" } } } ] [ "a=b&a=c" query>assoc ] unit-test

[ "a=3" ] [ { { "a" 3 } } assoc>query ] unit-test

: lf>crlf "\n" split "\r\n" join ;

STRING: read-request-test-1
GET http://foo/bar HTTP/1.1
Some-Header: 1
Some-Header: 2
Content-Length: 4

blah
;

[
    TUPLE{ request
        protocol: http
        port: 80
        method: "GET"
        path: "/bar"
        query: H{ }
        version: "1.1"
        header: H{ { "some-header" "1; 2" } { "content-length" "4" } }
        post-data: "blah"
        cookies: V{ }
    }
] [
    read-request-test-1 lf>crlf [
        read-request
    ] with-string-reader
] unit-test

STRING: read-request-test-1'
GET /bar HTTP/1.1
content-length: 4
some-header: 1; 2

blah
;

read-request-test-1' 1array [
    read-request-test-1 lf>crlf
    [ read-request ] with-string-reader
    [ write-request ] with-string-writer
    ! normalize crlf
    string-lines "\n" join
] unit-test

STRING: read-request-test-2
HEAD  http://foo/bar   HTTP/1.1
Host: www.sex.com

;

[
    TUPLE{ request
        protocol: http
        port: 80
        method: "HEAD"
        path: "/bar"
        query: H{ }
        version: "1.1"
        header: H{ { "host" "www.sex.com" } }
        host: "www.sex.com"
        cookies: V{ }
    }
] [
    read-request-test-2 lf>crlf [
        read-request
    ] with-string-reader
] unit-test

STRING: read-response-test-1
HTTP/1.1 404 not found
Content-Type: text/html; charset=UTF8

blah
;

[
    TUPLE{ response
        version: "1.1"
        code: 404
        message: "not found"
        header: H{ { "content-type" "text/html; charset=UTF8" } }
        cookies: V{ }
        content-type: "text/html"
        content-charset: "UTF8"
    }
] [
    read-response-test-1 lf>crlf
    [ read-response ] with-string-reader
] unit-test


STRING: read-response-test-1'
HTTP/1.1 404 not found
content-type: text/html; charset=UTF8


;

read-response-test-1' 1array [
    read-response-test-1 lf>crlf
    [ read-response ] with-string-reader
    [ write-response ] with-string-writer
    ! normalize crlf
    string-lines "\n" join
] unit-test

[ t ] [
    "rmid=732423sdfs73242; path=/; domain=.example.net; expires=Fri, 31-Dec-2010 23:59:59 GMT"
    dup parse-cookies unparse-cookies =
] unit-test

! Live-fire exercise
USING: http.server http.server.static http.server.sessions
http.server.actions http.server.auth.login http.server.db http.client
io.server io.files io io.encodings.ascii
accessors namespaces threads ;

: add-quit-action
    <action>
        [ stop-server [ "Goodbye" write ] <html-content> ] >>display
    "quit" add-responder ;

: test-db "test.db" temp-file sqlite-db ;

[ test-db drop delete-file ] ignore-errors

test-db [
    init-sessions-table
] with-db

[ ] [
    [
        <dispatcher>
            add-quit-action
            <dispatcher>
                "resource:extra/http/test" <static> >>default
            "nested" add-responder
            <action>
                [ "redirect-loop" f <standard-redirect> ] >>display
            "redirect-loop" add-responder
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

[ t ] [
    "resource:extra/http/test/foo.html" ascii file-contents
    "http://localhost:1237/nested/foo.html" http-get =
] unit-test

! Try with a slightly malformed request
[ t ] [
    "localhost" 1237 <inet> ascii [
        "GET nested HTTP/1.0\r\n" write flush
        "\r\n" write flush
        read-crlf drop
        read-header
    ] with-client "location" swap at "/" head?
] unit-test

[ "http://localhost:1237/redirect-loop" http-get ]
[ too-many-redirects? ] must-fail-with

[ "Goodbye" ] [
    "http://localhost:1237/quit" http-get
] unit-test

! Dispatcher bugs
[ ] [
    [
        <dispatcher>
            <action> f <protected>
            <login>
            <sessions>
            "" add-responder
            add-quit-action
            <dispatcher>
                <action> "a" add-main-responder
            "d" add-responder
        test-db <db-persistence>
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

: 404? [ download-failed? ] [ response>> code>> 404 = ] bi and ;

! This should give a 404 not an infinite redirect loop
[ "http://localhost:1237/d/blah" http-get ] [ 404? ] must-fail-with

! This should give a 404 not an infinite redirect loop
[ "http://localhost:1237/blah/" http-get ] [ 404? ] must-fail-with

[ "Goodbye" ] [ "http://localhost:1237/quit" http-get ] unit-test

[ ] [
    [
        <dispatcher>
            <action> [ [ "Hi" write ] <text-content> ] >>display
            <login>
            <sessions>
            "" add-responder
            add-quit-action
        test-db <db-persistence>
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

[ "Hi" ] [ "http://localhost:1237/" http-get ] unit-test

[ "Goodbye" ] [ "http://localhost:1237/quit" http-get ] unit-test

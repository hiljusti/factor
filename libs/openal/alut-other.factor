! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal
USING: kernel alien shuffle ;

LIBRARY: alut

FUNCTION: void alutLoadWAVFile ( ALbyte* fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency, ALboolean* looping ) ;

: load-wav-file ( filename -- format data size frequency )
  0 <int> f <void*> 0 <int> 0 <int>
  [ 0 <char> alutLoadWAVFile ] 4keep
  >r >r >r *int r> *void* r> *int r> *int ;

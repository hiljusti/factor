USING: alien sequences ;
{
    { "advapi32" "advapi32.dll" "stdcall" }
    { "gdi32"    "gdi32.dll"    "stdcall" }
    { "user32"   "user32.dll"   "stdcall" }
    { "kernel32" "kernel32.dll" "stdcall" }
    { "winsock"  "ws2_32.dll"   "stdcall" }
    { "mswsock"  "mswsock.dll"  "stdcall" }
    { "libc"     "msvcrt.dll"   "cdecl"   }
    { "libm"     "msvcrt.dll"   "cdecl"   }
} [ first3 add-library ] each

PROVIDE: core/windows/dlls ;

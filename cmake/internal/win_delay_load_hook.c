/* Resolve Node imports from the current host (including renamed executables). */
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#include <delayimp.h>
#include <string.h>

static FARPROC WINAPI ungyp_load_host(unsigned int notification, PDelayLoadInfo info) {
    HMODULE host;
    if (notification != dliNotePreLoadLibrary || _stricmp(info->szDll, "node.exe") != 0)
        return NULL;
    host = GetModuleHandleW(L"libnode.dll");
    if (host == NULL)
        host = GetModuleHandleW(NULL);
    return (FARPROC)host;
}

#ifdef __cplusplus
extern "C" {
#endif
const PfnDliHook __pfnDliNotifyHook2 = ungyp_load_host;
#ifdef __cplusplus
}
#endif

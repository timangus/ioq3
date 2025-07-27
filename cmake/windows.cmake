# Windows specific settings

if(NOT WIN32)
    return()
endif()

list(APPEND SYSTEM_PLATFORM_SOURCES
    ${SOURCE_DIR}/sys/sys_win32.c
    ${SOURCE_DIR}/sys/con_passive.c
)

list(APPEND CLIENT_PLATFORM_SOURCES
    ${SOURCE_DIR}/client/cl_http_windows.c
)

list(APPEND COMMON_LIBS ws2_32 winmm psapi)

if(MINGW)
    list(APPEND COMMON_LIBS mingw32)
endif()

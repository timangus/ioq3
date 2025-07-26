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

set(SDL2_INCLUDE_DIRS "${SOURCE_DIR}/SDL2-2.32.8/include")

if(MINGW)
    set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/win64/libSDL2main.a ${SOURCE_DIR}/libs/win64/libSDL2.dll.a)
else()
    set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/win64/SDL2main.lib ${SOURCE_DIR}/libs/win64/SDL2.lib)
endif()

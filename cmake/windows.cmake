# Windows specific settings

set(SYSTEM_PLATFORM_SOURCES
    ${SOURCE_DIR}/sys/sys_win32.c
    ${SOURCE_DIR}/sys/con_passive.c
)

set(CLIENT_PLATFORM_SOURCES
    ${SOURCE_DIR}/client/cl_http_windows.c
)

set(COMMON_LIBS ws2_32 winmm psapi)

set(SDL2_INCLUDE_DIRS "${SOURCE_DIR}/SDL2-2.32.8/include")
set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/win64/SDL2main.lib ${SOURCE_DIR}/libs/win64/SDL2.lib)

# Unix specific settings (this include macOS)

if(NOT UNIX)
    return()
endif()

list(APPEND SYSTEM_PLATFORM_SOURCES
    ${SOURCE_DIR}/sys/sys_unix.c
    ${SOURCE_DIR}/sys/con_tty.c
)

list(APPEND CLIENT_PLATFORM_SOURCES
    ${SOURCE_DIR}/client/cl_http_curl.c
)

list(APPEND COMMON_LIBS dl m)

find_package(PkgConfig REQUIRED)
pkg_check_modules(SDL2 REQUIRED sdl2)

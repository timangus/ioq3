# Windows specific settings

if(NOT WIN32)
    return()
endif()

list(APPEND SYSTEM_PLATFORM_SOURCES
    ${SOURCE_DIR}/sys/sys_win32.c
    ${SOURCE_DIR}/sys/con_passive.c
    ${SOURCE_DIR}/sys/win_resource.rc
)

list(APPEND CLIENT_PLATFORM_SOURCES
    ${SOURCE_DIR}/client/cl_http_windows.c
)

list(APPEND COMMON_LIBRARIES ws2_32 winmm psapi)

if(MINGW)
    list(APPEND COMMON_LIBRARIES mingw32)
endif()

# This is so the resource compiler can find the icon
list(APPEND SERVER_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/misc)
list(APPEND CLIENT_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/misc)

if(MSVC)
    # We have our own manifest, disable auto creation
    list(APPEND SERVER_LINK_OPTIONS "/MANIFEST:NO")
    list(APPEND CLIENT_LINK_OPTIONS "/MANIFEST:NO")
endif()

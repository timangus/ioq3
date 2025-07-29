# macOS specific settings

if(NOT APPLE)
    return()
endif()

enable_language(OBJC)

list(APPEND SYSTEM_PLATFORM_SOURCES ${SOURCE_DIR}/sys/sys_osx.m)

list(APPEND COMMON_LIBRARIES "-framework Cocoa")
list(APPEND CLIENT_LIBRARIES "-framework IOKit")
list(APPEND RENDERER_LIBRARIES "-framework OpenGL")

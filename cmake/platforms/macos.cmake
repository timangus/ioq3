# macOS specific settings

if(NOT APPLE)
    return()
endif()

# Including the arch in the filename doesn't really make sense
# on macOS where we're building Universal Binaries
set(USE_ARCHLESS_FILENAMES ON CACHE INTERNAL "")

enable_language(OBJC)

list(APPEND SYSTEM_PLATFORM_SOURCES ${SOURCE_DIR}/sys/sys_osx.m)

list(APPEND COMMON_LIBRARIES "-framework Cocoa")
list(APPEND CLIENT_LIBRARIES "-framework IOKit")
list(APPEND RENDERER_LIBRARIES "-framework OpenGL")

set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
set(SERVER_EXECUTABLE_OPTIONS MACOSX_BUNDLE)
set(CLIENT_EXECUTABLE_OPTIONS MACOSX_BUNDLE)

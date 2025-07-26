# macOS specific settings

if(NOT APPLE)
    return()
endif()

enable_language(OBJC)

list(APPEND SYSTEM_PLATFORM_SOURCES
    ${SOURCE_DIR}/sys/sys_osx.m
)

list(APPEND COMMON_LIBS "-framework Cocoa")

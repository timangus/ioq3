# macOS specific settings

list(APPEND SYSTEM_PLATFORM_SOURCES
    ${SOURCE_DIR}/sys/sys_osx.m
)

list(APPEND COMMON_LIBS "-framework Cocoa")

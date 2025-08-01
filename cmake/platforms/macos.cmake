# macOS specific settings

if(NOT APPLE)
    return()
endif()

# Including the arch in the filename doesn't really make sense
# on macOS where we're building Universal Binaries
set(USE_ARCHLESS_FILENAMES ON CACHE INTERNAL "")

option(BUILD_MACOS_APP "Deploy as a macOS .app" ON)

enable_language(OBJC)

list(APPEND SYSTEM_PLATFORM_SOURCES ${SOURCE_DIR}/sys/sys_osx.m)

list(APPEND COMMON_LIBRARIES "-framework Cocoa")
list(APPEND CLIENT_LIBRARIES "-framework IOKit")
list(APPEND RENDERER_LIBRARIES "-framework OpenGL")

set(CMAKE_OSX_DEPLOYMENT_TARGET 11.0)
set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)

if(BUILD_MACOS_APP)
    set(CLIENT_EXECUTABLE_OPTIONS MACOSX_BUNDLE)
    set(POST_CLIENT_CONFIGURE_FUNCTION finish_macos_app)
endif()

function(finish_macos_app)
    get_filename_component(MACOS_ICON_FILE ${MACOS_ICON_PATH} NAME)

    set_target_properties(${CLIENT_BINARY} PROPERTIES
        MACOSX_BUNDLE_BUNDLE_NAME "${CLIENT_NAME}"
        MACOSX_BUNDLE_GUI_IDENTIFIER "${MACOS_BUNDLE_ID}"
        MACOSX_BUNDLE_ICON_FILE ${MACOS_ICON_FILE}
        MACOSX_BUNDLE_SHORT_VERSION_STRING "${PRODUCT_VERSION}"
        MACOSX_BUNDLE_VERSION "${PRODUCT_VERSION}")

    set(RESOURCES_DIR $<TARGET_FILE_DIR:${CLIENT_BINARY}>/../Resources)
    add_custom_command(TARGET ${CLIENT_BINARY} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RESOURCES_DIR}
        COMMAND ${CMAKE_COMMAND} -E copy ${MACOS_ICON_PATH} ${RESOURCES_DIR})

    if(USE_RENDERER_DLOPEN)
        set(MACOS_APP_BINARY_DIR ${CLIENT_BINARY}.app/Contents/MacOS)

        if(BUILD_RENDERER_GL1)
            set_output_dirs(${RENDERER_GL1_BINARY} SUBDIRECTORY ${MACOS_APP_BINARY_DIR})
        endif()

        if(BUILD_RENDERER_GL2)
            set_output_dirs(${RENDERER_GL2_BINARY} SUBDIRECTORY ${MACOS_APP_BINARY_DIR})
        endif()
    endif()
endfunction()

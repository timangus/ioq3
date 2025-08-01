set(INTERNAL_SDL_DIR ${SOURCE_DIR}/SDL2-2.32.8)

if(NOT WIN32 AND NOT APPLE)
    set(SYSTEM_SDL_REQUIRED REQUIRED)
endif()

find_package(SDL2 QUIET ${SYSTEM_SDL_REQUIRED})

if(NOT SDL2_FOUND)
    set(SDL2_INCLUDE_DIRS ${INTERNAL_SDL_DIR}/include)

    # On Windows and macOS we have internal SDL binaries we can use
    if(WIN32)
        if(MINGW)
            set(SDL2_LIBRARIES
                ${SOURCE_DIR}/libs/win64/libSDL2main.a
                ${SOURCE_DIR}/libs/win64/libSDL2.dll.a)
        elseif(MSVC)
            set(SDL2_LIBRARIES
                ${SOURCE_DIR}/libs/win64/SDL2main.lib
                ${SOURCE_DIR}/libs/win64/SDL2.lib)
        endif()

        list(APPEND CLIENT_DEPLOY_LIBRARIES ${SOURCE_DIR}/libs/win64/SDL2.dll)
    elseif(APPLE)
        set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/macos/libSDL2main.a ${SOURCE_DIR}/libs/macos/libSDL2-2.0.0.dylib)
        list(APPEND CLIENT_DEPLOY_LIBRARIES ${SOURCE_DIR}/libs/macos/libSDL2-2.0.0.dylib)
    else()
        message(FATAL_ERROR "SDL2 not found and no internal binaries available")
    endif()
endif()

list(APPEND CLIENT_LIBRARIES ${SDL2_LIBRARIES})
list(APPEND CLIENT_INCLUDE_DIRS ${SDL2_INCLUDE_DIRS})
list(APPEND CLIENT_COMPILE_OPTIONS ${SDL2_CFLAGS_OTHER})
list(APPEND RENDERER_LIBRARIES ${SDL2_LIBRARIES})
list(APPEND RENDERER_INCLUDE_DIRS ${SDL2_INCLUDE_DIRS})
list(APPEND RENDERER_COMPILE_OPTIONS ${SDL2_CFLAGS_OTHER})

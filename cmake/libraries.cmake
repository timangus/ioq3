set(INTERNAL_SDL_DIR "${SOURCE_DIR}/SDL2-2.32.8")
set(INTERNAL_ZLIB_DIR "${SOURCE_DIR}/zlib-1.3.1")
set(INTERNAL_JPEG_DIR "${SOURCE_DIR}/jpeg-9f")
set(INTERNAL_OPENAL_DIR "${SOURCE_DIR}/openal-soft-1.24.3")
set(INTERNAL_CURL_DIR "${SOURCE_DIR}/curl-8.15.0")

function(find_include_dirs OUT_VAR)
    set(SOURCES ${ARGN})

    # Get top most common directory prefix for all source files
    set(COMMON_PATH "")
    foreach(FILE IN LISTS SOURCES)
        get_filename_component(DIR "${FILE}" DIRECTORY)
        file(REAL_PATH "${DIR}" DIR)
        if(COMMON_PATH STREQUAL "")
            set(COMMON_PATH "${DIR}")
        else()
            string(LENGTH "${COMMON_PATH}" PREFIX_LEN)
            while(NOT "${DIR}" MATCHES "^${COMMON_PATH}(/|$)" AND PREFIX_LEN GREATER 0)
                string(SUBSTRING "${COMMON_PATH}" 0 ${PREFIX_LEN} COMMON_PATH)
                math(EXPR PREFIX_LEN "${PREFIX_LEN} - 1")
            endwhile()
        endif()
    endforeach()

    if(NOT IS_DIRECTORY "${COMMON_PATH}")
        message(FATAL_ERROR "Could not determine common directory for source files")
    endif()

    # Recursively find directories that contain .h files under common directory
    file(GLOB_RECURSE HEADER_FILES "${COMMON_PATH}/*.h")
    set(INCLUDE_DIRS "")
    foreach(HEADER_FILE IN LISTS HEADER_FILES)
        get_filename_component(HEADER_DIR "${HEADER_FILE}" DIRECTORY)
        list(APPEND INCLUDE_DIRS "${HEADER_DIR}")
    endforeach()

    list(REMOVE_DUPLICATES INCLUDE_DIRS)

    set(${OUT_VAR} "${INCLUDE_DIRS}" PARENT_SCOPE)
endfunction()


######## ZLIB
if(USE_INTERNAL_ZLIB)
    file(GLOB_RECURSE ZLIB_SOURCES "${INTERNAL_ZLIB_DIR}/*.c")
    find_include_dirs(ZLIB_INCLUDE_DIRS "${ZLIB_SOURCES}")
    set(ZLIB_LIBRARIES "")
    set(ZLIB_DEFINITIONS "NO_GZIP")
    list(APPEND SERVER_LIBRARY_SOURCES ${ZLIB_SOURCES})
    list(APPEND CLIENT_LIBRARY_SOURCES ${ZLIB_SOURCES})
else()
    find_package(ZLIB REQUIRED)
endif()

list(APPEND SERVER_LIBRARIES ${ZLIB_LIBRARIES})
list(APPEND SERVER_INCLUDE_DIRS ${ZLIB_INCLUDE_DIRS})
list(APPEND SERVER_DEFINITIONS ${ZLIB_DEFINITIONS})
list(APPEND CLIENT_LIBRARIES ${ZLIB_LIBRARIES})
list(APPEND CLIENT_INCLUDE_DIRS ${ZLIB_INCLUDE_DIRS})
list(APPEND CLIENT_DEFINITIONS ${ZLIB_DEFINITIONS})


######### JPEG
if(USE_INTERNAL_JPEG)
    file(GLOB_RECURSE JPEG_SOURCES "${INTERNAL_JPEG_DIR}/j*.c")
    find_include_dirs(JPEG_INCLUDE_DIRS "${JPEG_SOURCES}")
    set(JPEG_LIBRARIES "")
    set(JPEG_DEFINITIONS "USE_INTERNAL_JPEG")
    list(APPEND RENDERER_LIBRARY_SOURCES ${JPEG_SOURCES})
else()
    find_package(JPEG REQUIRED)
endif()

list(APPEND RENDERER_LIBRARIES ${JPEG_LIBRARIES})
list(APPEND RENDERER_INCLUDE_DIRS ${JPEG_INCLUDE_DIRS})
list(APPEND RENDERER_DEFINITIONS ${JPEG_DEFINTIONS})


######### SDL
if(NOT WIN32 AND NOT APPLE)
    set(SYSTEM_SDL_REQUIRED REQUIRED)
endif()

find_package(SDL2 QUIET ${SYSTEM_SDL_REQUIRED})

if(NOT SDL2_FOUND)
    set(SDL2_INCLUDE_DIRS ${INTERNAL_SDL_DIR}/include)

    # On Windows and macOS we have internal SDL binaries we can use
    if(MINGW)
        set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/win64/libSDL2main.a ${SOURCE_DIR}/libs/win64/libSDL2.dll.a)
    elseif(WIN32)
        set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/win64/SDL2main.lib ${SOURCE_DIR}/libs/win64/SDL2.lib)
    elseif(APPLE)
        set(SDL2_LIBRARIES ${SOURCE_DIR}/libs/macos/libSDL2main.a ${SOURCE_DIR}/libs/macos/libSDL2-2.0.0.dylib)
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


######### OPENAL
if(USE_OPENAL)
    find_package(OpenAL QUIET)

    if(NOT OpenAL_FOUND)
        set(OPENAL_DEFINITIONS USE_INTERNAL_OPENAL_HEADERS)
        set(OPENAL_INCLUDE_DIR ${INTERNAL_OPENAL_DIR}/include)
        set(OPENAL_LIBRARY openal)
    endif()

    list(APPEND CLIENT_DEFINITIONS ${OPENAL_DEFINITIONS} USE_OPENAL)
    list(APPEND CLIENT_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR})

    if(USE_OPENAL_DLOPEN)
        list(APPEND CLIENT_DEFINITIONS USE_OPENAL_DLOPEN)
    else()
        find_package(Threads REQUIRED)
        list(APPEND CLIENT_LIBRARIES Threads::Threads ${OPENAL_LIBRARY})
    endif()
endif()


######### HTTP (CURL)
if(USE_HTTP AND NOT WIN32)
    find_package(CURL QUIET)

    if(NOT CURL_FOUND)
        set(CURL_DEFINITIONS USE_INTERNAL_CURL_HEADERS)
        set(CURL_INCLUDE_DIR ${INTERNAL_CURL_DIR}/include)
    endif()

    list(APPEND CLIENT_DEFINITIONS ${CURL_DEFINITIONS} USE_HTTP)
    list(APPEND CLIENT_INCLUDE_DIRS ${CURL_INCLUDE_DIR})
endif()

cmake_minimum_required(VERSION 3.20)
include(cmake/names.cmake)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES C ASM)

option(BUILD_SERVER "Build dedicated server" ON)
option(BUILD_CLIENT "Build client" ON)
option(BUILD_RENDERER_GL1 "Build GL1 renderer" ON)
option(BUILD_RENDERER_GL2 "Build GL2 renderer" ON)
option(BUILD_GAME_LIBRARIES "Build game module libraries" ON)
option(BUILD_GAME_QVMS "Build game module qvms" ON)
option(BUILD_STANDALONE "Build binaries for standalone games" OFF)

option(USE_INTERNAL_LIBS "Use internally packaged libraries" ON)
option(USE_INTERNAL_ZLIB "Use internal copy of zlib" ${USE_INTERNAL_LIBS})
option(USE_INTERNAL_JPEG "Use internal copy of libjpeg" ${USE_INTERNAL_LIBS})
option(USE_INTERNAL_OGG "Use internal copy of ogg" ${USE_INTERNAL_LIBS})
option(USE_INTERNAL_VORBIS "Use internal copy of vorbis" ${USE_INTERNAL_LIBS})
option(USE_INTERNAL_OPUS "Use internal copy of opus" ${USE_INTERNAL_LIBS})

option(USE_RENDERER_DLOPEN "Dynamically load the renderer(s)" ON)

option(USE_OPENAL "OpenAL audio" ON)
option(USE_OPENAL_DLOPEN "Dynamically load OpenAL" ON)
option(USE_HTTP "HTTP download support" ON)
option(USE_CODEC_VORBIS "Ogg Vorbis support" ON)
option(USE_CODEC_OPUS "Ogg Opus support" ON)
option(USE_VOIP "Voice chat" ON)
option(USE_MUMBLE "Mumble support" ON)

# Release build by default, set externally if you want something else
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_SHARED_LIBRARY_PREFIX "")

set(PRODUCT_VERSION "${CMAKE_PROJECT_VERSION}")

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" CPU)
if(CPU MATCHES "^(i386|i686|x86)$")
    set(ARCH "x86")
elseif(CPU MATCHES "^(amd64|x86_64)$")
    set(ARCH "x86_64")
elseif(CPU MATCHES "^(arm|armv7l)$")
    set(ARCH "arm")
elseif(CPU MATCHES "^(arm64|aarch64)$")
    set(ARCH "arm64")
elseif(CPU MATCHES "^(ppc|powerpc)$")
    set(ARCH "ppc")
elseif(CPU MATCHES "^(ppc64|powerpc64)$")
    set(ARCH "ppc64")
else()
    set(ARCH "unknown")
endif()

add_compile_definitions(
    ARCH_STRING="${ARCH}"
    PRODUCT_VERSION="${PRODUCT_VERSION}")

set(SOURCE_DIR ${CMAKE_SOURCE_DIR}/code)

include(cmake/compilers/msvc.cmake)
include(cmake/compilers/gnu.cmake)

include(cmake/platforms/windows.cmake)
include(cmake/platforms/unix.cmake)
include(cmake/platforms/macos.cmake)

include(cmake/libraries/all.cmake)

include(cmake/server.cmake)
include(cmake/client.cmake)
include(cmake/renderer_gl1.cmake)
include(cmake/renderer_gl2.cmake)
include(cmake/basegame.cmake)
include(cmake/missionpack.cmake)

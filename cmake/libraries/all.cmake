# Read library versions from the single source of truth (misc/lib-versions.sh)
file(STRINGS ${CMAKE_SOURCE_DIR}/misc/lib-versions.sh _lib_version_lines
     REGEX "^[A-Z_]+=[^ ]+")
foreach(_line ${_lib_version_lines})
    if(_line MATCHES "^([A-Z_]+)=(.+)$")
        set(${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
    endif()
endforeach()
unset(_lib_version_lines)
unset(_line)

set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
             ${CMAKE_SOURCE_DIR}/misc/lib-versions.sh)

include(libraries/curl)
include(libraries/freetype)
include(libraries/jpeg)
include(libraries/ogg)
include(libraries/opus)
include(libraries/openal)
include(libraries/sdl)
include(libraries/vorbis)
include(libraries/zlib)

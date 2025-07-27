cmake_minimum_required(VERSION 3.20)
include(cmake/names.cmake)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES C ASM)

option(BUILD_SERVER "Build dedicated server" ON)
option(BUILD_CLIENT "Build client" ON)
option(BUILD_RENDERER_GL1 "Build GL1 renderer" ON)
option(BUILD_RENDERER_GL2 "Build GL2 renderer" ON)
option(BUILD_GAME_LIBRARIES "Build game module libraries" ON)
option(BUILD_GAME_QVMS "Build game module qvms" ON)

option(USE_INTERNAL_LIBS "Use internally packaged libraries" ON)
option(USE_INTERNAL_ZLIB "Use internal copy of zlib" ${USE_INTERNAL_LIBS})
option(USE_INTERNAL_JPEG "Use internal copy of libjpeg" ${USE_INTERNAL_LIBS})

option(USE_RENDERER_DLOPEN "Dynamically load the renderer(s)" ON)

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
    PRODUCT_VERSION="${PRODUCT_VERSION}"
)

list(APPEND SERVER_DEFINITIONS DEDICATED)

list(APPEND SERVER_DEFINITIONS BOTLIB)
list(APPEND CLIENT_DEFINITIONS BOTLIB)

if(USE_RENDERER_DLOPEN)
    list(APPEND CLIENT_DEFINITIONS USE_RENDERER_DLOPEN)
    list(APPEND RENDERER_DEFINITIONS USE_RENDERER_DLOPEN)
elseif(BUILD_RENDERER_GL1 AND BUILD_RENDERER_GL2)
    message(FATAL_ERROR "Multiple static renderers enabled; choose one")
endif()

set(SOURCE_DIR ${CMAKE_SOURCE_DIR}/code)

include(cmake/msvc.cmake)
include(cmake/gnu.cmake)

include(cmake/windows.cmake)
include(cmake/unix.cmake)
include(cmake/macos.cmake)

include(cmake/sources.cmake)

include(cmake/libraries.cmake)

list(APPEND RENDERER_LIBRARIES
    ${COMMON_LIBRARIES}
    ${JPEG_LIBRARIES}
    ${SDL2_LIBRARIES})

list(APPEND RENDERER_INCLUDE_DIRS
    ${JPEG_INCLUDE_DIRS}
    ${SDL2_INCLUDE_DIRS})

list(APPEND RENDERER_DEFINITIONS ${JPEG_DEFINTIONS})
list(APPEND RENDERER_COMPILE_OPTIONS ${SDL2_CFLAGS_OTHER})

set(SERVER_BINARY "${SERVER_NAME}.${ARCH}")
set(CLIENT_BINARY "${CLIENT_NAME}.${ARCH}")

set(RENDERER_GL1_BINARY "renderer_opengl1_${ARCH}")
set(RENDERER_GL2_BINARY "renderer_opengl2_${ARCH}")

set(CGAME_MODULE_BINARY "${CGAME_MODULE}${ARCH}")
set(CGAME_MODULE_BINARY_BASEGAME "${CGAME_MODULE_BINARY}_${BASEGAME}")
set(CGAME_MODULE_QVM "${CGAME_MODULE}qvm")
set(CGAME_MODULE_QVM_BASEGAME "${CGAME_MODULE_QVM}_${BASEGAME}")

set(GAME_MODULE_BINARY "${GAME_MODULE}${ARCH}")
set(GAME_MODULE_BINARY_BASEGAME "${GAME_MODULE_BINARY}_${BASEGAME}")
set(GAME_MODULE_QVM "${GAME_MODULE}qvm")
set(GAME_MODULE_QVM_BASEGAME "${GAME_MODULE_QVM}_${BASEGAME}")

set(UI_MODULE_BINARY "${UI_MODULE}${ARCH}")
set(UI_MODULE_BINARY_BASEGAME "${UI_MODULE_BINARY}_${BASEGAME}")
set(UI_MODULE_QVM "${UI_MODULE}qvm")
set(UI_MODULE_QVM_BASEGAME "${UI_MODULE_QVM}_${BASEGAME}")

function(set_output_dirs TARGET)
    list(REMOVE_AT ARGV 0)
    cmake_parse_arguments(ARG "" "" "SUBDIRECTORY" ${ARGV})

    if(CMAKE_CONFIGURATION_TYPES) # Multi-config
        set(CONFIGS ${CMAKE_CONFIGURATION_TYPES})
    else() # Single-config
        set(CONFIGS ${CMAKE_BUILD_TYPE})
    endif()

    foreach(CONFIG ${CONFIGS})
        string(TOUPPER "${CONFIG}" CONFIG_UPPER)

        if(ARG_SUBDIRECTORY)
            set(LIB_DIR "${CMAKE_BINARY_DIR}/${CONFIG}/${ARG_SUBDIRECTORY}")
        else()
            set(LIB_DIR "${CMAKE_BINARY_DIR}/${CONFIG}")
        endif()

        set_target_properties(${TARGET} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY_${CONFIG_UPPER} "${LIB_DIR}"
            RUNTIME_OUTPUT_DIRECTORY_${CONFIG_UPPER} "${LIB_DIR}"
            ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_UPPER} "${LIB_DIR}"
        )
    endforeach()
endfunction()

if(BUILD_SERVER)
    set(SERVER_BINARY_SOURCES
        ${SERVER_SOURCES}
        ${NULL_SOURCES}
        ${COMMON_SOURCES}
        ${BOTLIB_SOURCES}
        ${SYSTEM_SOURCES}
        ${ASM_SOURCES}
        ${ZLIB_SOURCES}
    )

    add_executable(${SERVER_BINARY} ${SERVER_BINARY_SOURCES})
    target_include_directories(${SERVER_BINARY} PRIVATE
        ${ZLIB_INCLUDE_DIRS})
    target_link_libraries(${SERVER_BINARY}
        ${COMMON_LIBRARIES}
        ${SERVER_LIBRARIES}
        ${ZLIB_LIBRARIES})
    target_compile_definitions(${SERVER_BINARY} PRIVATE
        ${SERVER_DEFINITIONS}
        ${ZLIB_DEFINITIONS})
    set_output_dirs(${SERVER_BINARY})
endif()

if(BUILD_RENDERER_GL1)
    set(RENDERER_GL1_BINARY_SOURCES
        ${RENDERER_COMMON_SOURCES}
        ${RENDERER_GL1_SOURCES}
        ${SDL_RENDERER_SOURCES}
        ${JPEG_SOURCES}
    )

    if(USE_RENDERER_DLOPEN)
        list(APPEND RENDERER_GL1_BINARY_SOURCES ${DYNAMIC_RENDERER_SOURCES})

        add_library(${RENDERER_GL1_BINARY} SHARED ${RENDERER_GL1_BINARY_SOURCES})
        target_link_libraries(${RENDERER_GL1_BINARY} PRIVATE ${RENDERER_LIBRARIES})
        target_include_directories(${RENDERER_GL1_BINARY} PRIVATE ${RENDERER_INCLUDE_DIRS})
        target_compile_definitions(${RENDERER_GL1_BINARY} PRIVATE ${RENDERER_DEFINITIONS})
        target_compile_options(${RENDERER_GL1_BINARY} PRIVATE ${RENDERER_COMPILE_OPTIONS})
        set_output_dirs(${RENDERER_GL1_BINARY})
    endif()
endif()

if(BUILD_RENDERER_GL2)
    set(SHADERS_DIR "${CMAKE_BINARY_DIR}/shaders.dir")
    file(MAKE_DIRECTORY ${SHADERS_DIR})

    foreach(SHADER_FILE IN LISTS RENDERER_GL2_SHADER_SOURCES)
        get_filename_component(SHADER_NAME "${SHADER_FILE}" NAME_WE)
        set(SHADER_C_FILE "${SHADERS_DIR}/${SHADER_NAME}.c")

        string(REPLACE "${CMAKE_BINARY_DIR}/" "" SHADER_C_FILE_COMMENT "${SHADER_C_FILE}")

        add_custom_command(
            OUTPUT ${SHADER_C_FILE}
            COMMAND ${CMAKE_COMMAND}
                -DINPUT_FILE=${SHADER_FILE}
                -DOUTPUT_FILE=${SHADER_C_FILE}
                -DSHADER_NAME=${SHADER_NAME}
                -P ${CMAKE_SOURCE_DIR}/cmake/stringify_shader.cmake
            DEPENDS ${SHADER_FILE}
            COMMENT "Stringify shader ${SHADER_C_FILE_COMMENT}"
        )

        list(APPEND RENDERER_GL2_SHADER_C_SOURCES ${SHADER_C_FILE})
    endforeach()

    set(RENDERER_GL2_BINARY_SOURCES
        ${RENDERER_COMMON_SOURCES}
        ${RENDERER_GL2_SOURCES}
        ${RENDERER_GL2_SHADER_C_SOURCES}
        ${SDL_RENDERER_SOURCES}
        ${JPEG_SOURCES}
    )

    if(USE_RENDERER_DLOPEN)
        list(APPEND RENDERER_GL2_BINARY_SOURCES ${DYNAMIC_RENDERER_SOURCES})

        add_library(${RENDERER_GL2_BINARY} SHARED ${RENDERER_GL2_BINARY_SOURCES})
        target_link_libraries(${RENDERER_GL2_BINARY} PRIVATE ${RENDERER_LIBRARIES})
        target_include_directories(${RENDERER_GL2_BINARY} PRIVATE ${RENDERER_INCLUDE_DIRS})
        target_compile_definitions(${RENDERER_GL2_BINARY} PRIVATE ${RENDERER_DEFINITIONS})
        target_compile_options(${RENDERER_GL2_BINARY} PRIVATE ${RENDERER_COMPILE_OPTIONS})
        set_output_dirs(${RENDERER_GL2_BINARY})
    endif()
endif()

if(BUILD_CLIENT)
    set(CLIENT_BINARY_SOURCES
        ${SERVER_SOURCES}
        ${CLIENT_SOURCES}
        ${COMMON_SOURCES}
        ${BOTLIB_SOURCES}
        ${SYSTEM_SOURCES}
        ${ASM_SOURCES}
        ${ZLIB_SOURCES}
        ${SDL_CLIENT_SOURCES}
    )

    if(NOT USE_RENDERER_DLOPEN)
        if(BUILD_RENDERER_GL1)
            list(APPEND CLIENT_BINARY_SOURCES ${RENDERER_GL1_BINARY_SOURCES})
        elseif(BUILD_RENDERER_GL2)
            list(APPEND CLIENT_BINARY_SOURCES ${RENDERER_GL2_BINARY_SOURCES})
        else()
            message(FATAL_ERROR "No renderer selected")
        endif()
    endif()

    add_executable(${CLIENT_BINARY} ${CLIENT_BINARY_SOURCES})
    target_include_directories(${CLIENT_BINARY} PRIVATE
        ${ZLIB_INCLUDE_DIRS}
        ${SDL2_INCLUDE_DIRS})
    target_link_libraries(${CLIENT_BINARY} PRIVATE
        ${COMMON_LIBRARIES}
        ${CLIENT_LIBRARIES}
        ${ZLIB_LIBRARIES}
        ${SDL2_LIBRARIES})
    target_compile_definitions(${CLIENT_BINARY} PRIVATE
        ${CLIENT_DEFINITIONS}
        ${ZLIB_DEFINITIONS})
    target_compile_options(${CLIENT_BINARY} PRIVATE
        ${SDL2_CFLAGS_OTHER})
    target_link_options(${CLIENT_BINARY} PRIVATE
        ${CLIENT_LINK_OPTIONS})
    set_output_dirs(${CLIENT_BINARY})

    if(NOT USE_RENDERER_DLOPEN)
        target_link_libraries(${CLIENT_BINARY} PRIVATE ${RENDERER_LIBRARIES})
        target_include_directories(${CLIENT_BINARY} PRIVATE ${RENDERER_INCLUDE_DIRS})
        target_compile_definitions(${CLIENT_BINARY} PRIVATE ${RENDERER_DEFINITIONS})
        target_compile_options(${CLIENT_BINARY} PRIVATE ${RENDERER_COMPILE_OPTIONS})
    endif()
endif()

if(BUILD_GAME_LIBRARIES OR BUILD_GAME_QVMS)
    set(CGAME_SOURCES_BASEGAME ${CGAME_SOURCES} ${GAME_MODULE_SHARED_SOURCES})
    set(GAME_SOURCES_BASEGAME ${GAME_SOURCES} ${GAME_MODULE_SHARED_SOURCES})
    set(UI_SOURCES_BASEGAME ${UI_SOURCES} ${GAME_MODULE_SHARED_SOURCES})
endif()

if(BUILD_GAME_LIBRARIES)
    add_library(${CGAME_MODULE_BINARY_BASEGAME} SHARED ${CGAME_SOURCES_BASEGAME} ${CGAME_BINARY_SOURCES})
    target_compile_definitions(${CGAME_MODULE_BINARY_BASEGAME} PRIVATE CGAME)
    set_target_properties(${CGAME_MODULE_BINARY_BASEGAME} PROPERTIES OUTPUT_NAME "${CGAME_MODULE_BINARY}")
    set_output_dirs(${CGAME_MODULE_BINARY_BASEGAME} SUBDIRECTORY ${BASEGAME})

    add_library(${GAME_MODULE_BINARY_BASEGAME} SHARED ${GAME_SOURCES_BASEGAME} ${GAME_BINARY_SOURCES})
    target_compile_definitions(${GAME_MODULE_BINARY_BASEGAME} PRIVATE QAGAME)
    set_target_properties(${GAME_MODULE_BINARY_BASEGAME} PROPERTIES OUTPUT_NAME "${GAME_MODULE_BINARY}")
    set_output_dirs(${GAME_MODULE_BINARY_BASEGAME} SUBDIRECTORY ${BASEGAME})

    add_library(${UI_MODULE_BINARY_BASEGAME} SHARED ${UI_SOURCES_BASEGAME} ${UI_BINARY_SOURCES})
    target_compile_definitions(${UI_MODULE_BINARY_BASEGAME} PRIVATE UI)
    set_target_properties(${UI_MODULE_BINARY_BASEGAME} PROPERTIES OUTPUT_NAME "${UI_MODULE_BINARY}")
    set_output_dirs(${UI_MODULE_BINARY_BASEGAME} SUBDIRECTORY ${BASEGAME})
endif()

if(BUILD_GAME_QVMS)
    add_executable(q3asm ${Q3ASM_SOURCES})
    set_output_dirs(q3asm SUBDIRECTORY tools)
    add_executable(q3lcc ${Q3LCC_SOURCES})
    set_output_dirs(q3lcc SUBDIRECTORY tools)
    add_dependencies(q3lcc q3rcc q3cpp)

    add_executable(lburg ${LBURG_SOURCES})
    set_output_dirs(lburg SUBDIRECTORY tools)
    set(DAGCHECK_C "${CMAKE_BINARY_DIR}/$<CONFIG>/tools/dagcheck.c")
    add_custom_command(
        OUTPUT ${DAGCHECK_C}
        COMMAND lburg ${Q3RCC_DAGCHECK_SOURCE} ${DAGCHECK_C}
        DEPENDS lburg ${Q3RCC_DAGCHECK_SOURCE}
    )

    add_executable(q3rcc ${Q3RCC_SOURCES} ${DAGCHECK_C})
    set_output_dirs(q3rcc SUBDIRECTORY tools)
    target_include_directories(q3rcc PRIVATE ${SOURCE_DIR}/tools/lcc/src)

    add_executable(q3cpp ${Q3CPP_SOURCES})
    set_output_dirs(q3cpp SUBDIRECTORY tools)

    function(add_qvm MODULE_NAME)
        list(REMOVE_AT ARGV 0)
        cmake_parse_arguments(ARG "" "" "DEFINITIONS;OUTPUT_NAME;OUTPUT_DIRECTORY;SOURCES" ${ARGV})

        set(QVM_OUTPUT_DIR "${CMAKE_BINARY_DIR}/$<CONFIG>")
        if(ARG_OUTPUT_DIRECTORY)
            set(QVM_OUTPUT_DIR "${QVM_OUTPUT_DIR}/${ARG_OUTPUT_DIRECTORY}")
        endif()
        add_custom_command(
            OUTPUT "${QVM_OUTPUT_DIR}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${QVM_OUTPUT_DIR}"
        )

        if(ARG_OUTPUT_NAME)
            set(QVM_FILE "${QVM_OUTPUT_DIR}/${ARG_OUTPUT_NAME}.qvm")
        else()
            set(QVM_FILE "${QVM_OUTPUT_DIR}/${MODULE_NAME}.qvm")
        endif()

        set(QVM_ASM_DIR "${CMAKE_BINARY_DIR}/qvm.dir/${MODULE_NAME}")
        file(MAKE_DIRECTORY ${QVM_ASM_DIR})

        set(LCC_FLAGS "")
        foreach(DEFINITION IN LISTS ARG_DEFINITIONS)
            list(APPEND LCC_FLAGS "-D${DEFINITION}")
        endforeach()

        set(ASM_FILES "")
        foreach(SOURCE ${ARG_SOURCES})
            if(${SOURCE} MATCHES "\\.asm$")
                list(APPEND ASM_FILES ${SOURCE})
                continue()
            endif()

            get_filename_component(BASE_FILE ${SOURCE} NAME_WE)
            set(ASM_FILE ${QVM_ASM_DIR}/${BASE_FILE}.asm)
            string(REPLACE "${CMAKE_BINARY_DIR}/" "" ASM_FILE_COMMENT "${ASM_FILE}")

            add_custom_command(
                OUTPUT ${ASM_FILE}
                COMMAND q3lcc ${LCC_FLAGS} -o ${ASM_FILE} ${SOURCE}
                DEPENDS ${SOURCE} q3lcc
                COMMENT "Building C object ${ASM_FILE_COMMENT}"
            )

            list(APPEND ASM_FILES ${ASM_FILE})
        endforeach()

        string(REPLACE "${CMAKE_BINARY_DIR}/" "" QVM_FILE_COMMENT "${QVM_FILE}")
        add_custom_command(
            OUTPUT ${QVM_FILE}
            COMMAND q3asm -o ${QVM_FILE} ${ASM_FILES}
            DEPENDS ${ASM_FILES} q3asm
            COMMENT "Linking C QVM library ${QVM_FILE_COMMENT}"
        )

        string(REGEX REPLACE "[^A-Za-z0-9]" "_" TARGET_NAME "${MODULE_NAME}")
        add_custom_target(${TARGET_NAME} ALL DEPENDS ${QVM_FILE})
    endfunction()

    add_qvm(${CGAME_MODULE_QVM_BASEGAME}
        DEFINITIONS CGAME
        OUTPUT_NAME "${CGAME_MODULE}"
        OUTPUT_DIRECTORY "${BASEGAME}/vm"
        SOURCES ${CGAME_SOURCES_BASEGAME} ${CGAME_QVM_SOURCES}
    )

    add_qvm(${GAME_MODULE_QVM_BASEGAME}
        DEFINITIONS QAGAME
        OUTPUT_NAME "${GAME_MODULE}"
        OUTPUT_DIRECTORY "${BASEGAME}/vm"
        SOURCES ${GAME_SOURCES_BASEGAME} ${GAME_QVM_SOURCES}
    )

    add_qvm(${UI_MODULE_QVM_BASEGAME}
        DEFINITIONS UI
        OUTPUT_NAME "${UI_MODULE}"
        OUTPUT_DIRECTORY "${BASEGAME}/vm"
        SOURCES ${UI_SOURCES_BASEGAME} ${UI_QVM_SOURCES}
    )
endif()

include(cmake/missionpack.cmake)

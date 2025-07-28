include_guard(GLOBAL)

if(NOT BUILD_GAME_QVMS)
    return()
endif()

include(cmake/utils/set_output_dirs.cmake)

set(Q3ASM_SOURCES
    ${SOURCE_DIR}/tools/asm/q3asm.c
    ${SOURCE_DIR}/tools/asm/cmdlib.c
)

set(Q3LCC_SOURCES
    ${SOURCE_DIR}/tools/lcc/etc/lcc.c
    ${SOURCE_DIR}/tools/lcc/etc/bytecode.c
)

set(Q3RCC_SOURCES
    ${SOURCE_DIR}/tools/lcc/src/alloc.c
    ${SOURCE_DIR}/tools/lcc/src/bind.c
    ${SOURCE_DIR}/tools/lcc/src/bytecode.c
    ${SOURCE_DIR}/tools/lcc/src/dag.c
    ${SOURCE_DIR}/tools/lcc/src/decl.c
    ${SOURCE_DIR}/tools/lcc/src/enode.c
    ${SOURCE_DIR}/tools/lcc/src/error.c
    ${SOURCE_DIR}/tools/lcc/src/event.c
    ${SOURCE_DIR}/tools/lcc/src/expr.c
    ${SOURCE_DIR}/tools/lcc/src/gen.c
    ${SOURCE_DIR}/tools/lcc/src/init.c
    ${SOURCE_DIR}/tools/lcc/src/inits.c
    ${SOURCE_DIR}/tools/lcc/src/input.c
    ${SOURCE_DIR}/tools/lcc/src/lex.c
    ${SOURCE_DIR}/tools/lcc/src/list.c
    ${SOURCE_DIR}/tools/lcc/src/main.c
    ${SOURCE_DIR}/tools/lcc/src/null.c
    ${SOURCE_DIR}/tools/lcc/src/output.c
    ${SOURCE_DIR}/tools/lcc/src/prof.c
    ${SOURCE_DIR}/tools/lcc/src/profio.c
    ${SOURCE_DIR}/tools/lcc/src/simp.c
    ${SOURCE_DIR}/tools/lcc/src/stmt.c
    ${SOURCE_DIR}/tools/lcc/src/string.c
    ${SOURCE_DIR}/tools/lcc/src/sym.c
    ${SOURCE_DIR}/tools/lcc/src/symbolic.c
    ${SOURCE_DIR}/tools/lcc/src/trace.c
    ${SOURCE_DIR}/tools/lcc/src/tree.c
    ${SOURCE_DIR}/tools/lcc/src/types.c
)

set(Q3RCC_DAGCHECK_SOURCE ${SOURCE_DIR}/tools/lcc/src/dagcheck.md)

set(Q3CPP_SOURCES
    ${SOURCE_DIR}/tools/lcc/cpp/cpp.c
    ${SOURCE_DIR}/tools/lcc/cpp/lex.c
    ${SOURCE_DIR}/tools/lcc/cpp/nlist.c
    ${SOURCE_DIR}/tools/lcc/cpp/tokens.c
    ${SOURCE_DIR}/tools/lcc/cpp/macro.c
    ${SOURCE_DIR}/tools/lcc/cpp/eval.c
    ${SOURCE_DIR}/tools/lcc/cpp/include.c
    ${SOURCE_DIR}/tools/lcc/cpp/hideset.c
    ${SOURCE_DIR}/tools/lcc/cpp/getopt.c
    ${SOURCE_DIR}/tools/lcc/cpp/unix.c
)

set(LBURG_SOURCES
    ${SOURCE_DIR}/tools/lcc/lburg/lburg.c
    ${SOURCE_DIR}/tools/lcc/lburg/gram.c
)

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
    DEPENDS lburg ${Q3RCC_DAGCHECK_SOURCE})

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
        COMMAND ${CMAKE_COMMAND} -E make_directory "${QVM_OUTPUT_DIR}")

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
            COMMENT "Building C object ${ASM_FILE_COMMENT}")

        list(APPEND ASM_FILES ${ASM_FILE})
    endforeach()

    string(REPLACE "${CMAKE_BINARY_DIR}/" "" QVM_FILE_COMMENT "${QVM_FILE}")
    add_custom_command(
        OUTPUT ${QVM_FILE}
        COMMAND q3asm -o ${QVM_FILE} ${ASM_FILES}
        DEPENDS ${ASM_FILES} q3asm
        COMMENT "Linking C QVM library ${QVM_FILE_COMMENT}")

    string(REGEX REPLACE "[^A-Za-z0-9]" "_" TARGET_NAME "${MODULE_NAME}")
    add_custom_target(${TARGET_NAME} ALL DEPENDS ${QVM_FILE})
endfunction()

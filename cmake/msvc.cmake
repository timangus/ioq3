# MSVC compiler specific settings

if(NOT CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    return()
endif()

enable_language(ASM_MASM)

add_compile_options("$<$<COMPILE_LANGUAGE:C>:/wd4267>")
add_compile_definitions(__inline__=__inline)
add_compile_definitions(_CRT_SECURE_NO_WARNINGS)

set(ASM_SOURCES
    ${SOURCE_DIR}/asm/snapvector.asm
    ${SOURCE_DIR}/asm/ftola.asm
)

if(ARCH MATCHES "x86_64")
    list(APPEND ASM_SOURCES ${SOURCE_DIR}/asm/vm_x86_64.asm)
    set_source_files_properties(
        ${ASM_SOURCES}
        PROPERTIES COMPILE_DEFINITIONS "idx64"
    )
endif()

# GNU style (GCC/Clang) compiler specific settings

if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_C_COMPILER_ID MATCHES "^(Apple)?Clang$")
    return()
endif()

set(ASM_SOURCES
    ${SOURCE_DIR}/asm/snapvector.c
    ${SOURCE_DIR}/asm/ftola.c
)

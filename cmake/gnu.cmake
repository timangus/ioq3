# GNU style (GCC/Clang) compiler specific settings

set(ASM_SOURCES
    ${SOURCE_DIR}/asm/snapvector.c
    ${SOURCE_DIR}/asm/ftola.c
)

if(MINGW)
    list(APPEND COMMON_LIBS mingw32)
endif()

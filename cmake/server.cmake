
if(NOT BUILD_SERVER)
    return()
endif()

set(SERVER_SOURCES
    ${SOURCE_DIR}/server/sv_bot.c
    ${SOURCE_DIR}/server/sv_client.c
    ${SOURCE_DIR}/server/sv_ccmds.c
    ${SOURCE_DIR}/server/sv_game.c
    ${SOURCE_DIR}/server/sv_init.c
    ${SOURCE_DIR}/server/sv_main.c
    ${SOURCE_DIR}/server/sv_net_chan.c
    ${SOURCE_DIR}/server/sv_snapshot.c
    ${SOURCE_DIR}/server/sv_world.c
)

set(NULL_SOURCES
    ${SOURCE_DIR}/null/null_client.c
    ${SOURCE_DIR}/null/null_input.c
    ${SOURCE_DIR}/null/null_snddma.c
)

set(SERVER_BINARY "${SERVER_NAME}.${ARCH}")

list(APPEND SERVER_DEFINITIONS DEDICATED)
list(APPEND SERVER_DEFINITIONS BOTLIB)

if(BUILD_STANDALONE)
    list(APPEND SERVER_DEFINITIONS STANDALONE)
endif()

list(APPEND SERVER_BINARY_SOURCES
    ${SERVER_SOURCES}
    ${NULL_SOURCES}
    ${COMMON_SOURCES}
    ${BOTLIB_SOURCES}
    ${SYSTEM_SOURCES}
    ${ASM_SOURCES}
    ${SERVER_LIBRARY_SOURCES})

add_executable(${SERVER_BINARY} ${SERVER_EXECUTABLE_OPTIONS} ${SERVER_BINARY_SOURCES})

target_include_directories(     ${SERVER_BINARY} PRIVATE ${SERVER_INCLUDE_DIRS})
target_compile_definitions(     ${SERVER_BINARY} PRIVATE ${SERVER_DEFINITIONS})
target_compile_options(         ${SERVER_BINARY} PRIVATE ${SERVER_COMPILE_OPTIONS})
target_link_libraries(          ${SERVER_BINARY} PRIVATE ${COMMON_LIBRARIES} ${SERVER_LIBRARIES})
target_link_options(            ${SERVER_BINARY} PRIVATE ${SERVER_LINK_OPTIONS})

set_output_dirs(${SERVER_BINARY})

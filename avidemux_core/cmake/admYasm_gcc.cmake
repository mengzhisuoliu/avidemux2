#
IF(ADM_CPU_X86)
  MESSAGE(STATUS "Checking for YASM")
  MESSAGE(STATUS "*****************")
  FIND_PROGRAM(YASM_YASM yasm)
  IF(YASM_YASM STREQUAL "<YASM_YASM>-NOTFOUND")
    MESSAGE(FATAL_ERROR "Yasm Not found. Stopping here.")
  ENDIF()
  MESSAGE(STATUS "Found as ${YASM_YASM}")

  SET(CMAKE_ASM_SOURCE_FILE_EXTENSIONS nasm;nas;asm)
  SET(ASM_ARGS "")
  IF(APPLE)
    SET(ASM_ARGS_FORMAT  -f macho64 -DPREFIX -DPIC)
  ELSE()
    IF(WIN32)
      IF(ADM_CPU_X86_64)
        SET(ASM_ARGS_FORMAT  -f win64)
      ELSE()
        SET(ASM_ARGS_FORMAT  -f win32)
      ENDIF()
    ELSE() # Linux
      SET(ASM_ARGS_FORMAT      -f elf -DPIC)
    ENDIF()
  ENDIF()

  IF(WIN32 AND NOT ADM_CPU_X86_64)
    SET(ASM_ARGS_FLAGS       -DHAVE_ALIGNED_STACK=0 -DPREFIX)
  ELSE()
    SET(ASM_ARGS_FLAGS       -DHAVE_ALIGNED_STACK=1)
  ENDIF()

  IF( ADM_CPU_X86_64 )
    SET(ASM_ARGS_FORMAT ${ASM_ARGS_FORMAT} -m amd64 -DARCH_X86_64=1 -DARCH_X86_32=0)
  ELSE()
    SET(ASM_ARGS_FORMAT ${ASM_ARGS_FORMAT}  -DARCH_X86_64=0 -DARCH_X86_32=1)
  ENDIF()

  SET(ASM_ARGS_FLAGS ${ASM_ARGS_FLAGS} -DHAVE_CPUNOP=0) # Not sure what this is for ?

  IF(AVIDEMUX_THIS_IS_CORE)
    SET(NASM_MACRO_FOLDER  ${AVIDEMUX_CORE_SOURCE_DIR}/ADM_core/include)
  ELSE()
    SET(NASM_MACRO_FOLDER  ${ADM_HEADER_DIR}/ADM_core/)
  ENDIF()

  IF(CMAKE_BUILD_TYPE STREQUAL "Debug")
    SET(ASM_ARGS_FLAGS ${ASM_ARGS_FLAGS} -gdwarf2)
  ENDIF()

  MACRO(YASMIFY out)
    MESSAGE(STATUS "YASMIFY : ${filez}")
    FOREACH(fl ${ARGN})
      MESSAGE(STATUS "    ${CMAKE_CURRENT_SOURCE_DIR}/${fl}.asm ==> ${CMAKE_CURRENT_BINARY_DIR}/${fl}.obj")
      add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${fl}.obj
        COMMAND ${CMAKE_COMMAND} -E echo   ${YASM_YASM} ARGS ${ASM_ARGS_FORMAT} ${ASM_ARGS_FLAGS} -I${NASM_MACRO_FOLDER}  -o ${CMAKE_CURRENT_BINARY_DIR}/${fl}.obj ${CMAKE_CURRENT_SOURCE_DIR}/${fl}.asm
        COMMAND ${YASM_YASM} ARGS ${ASM_ARGS_FORMAT} ${ASM_ARGS_FLAGS} -I${NASM_MACRO_FOLDER}  -o ${CMAKE_CURRENT_BINARY_DIR}/${fl}.obj ${CMAKE_CURRENT_SOURCE_DIR}/${fl}.asm
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${fl}.asm)
      LIST( APPEND ${out} ${CMAKE_CURRENT_BINARY_DIR}/${fl}.obj)
    ENDFOREACH()
    MESSAGE(STATUS "ASM files : ${${out}}")
  ENDMACRO()

ELSE()
  MESSAGE(STATUS "Not X86, no need for yasm")
  MACRO(YASMIFY)
  ENDMACRO()
ENDIF() # Temp hack
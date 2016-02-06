# Project Specific

# -----------------------------------------------------------------------------
# add_wet_test
# -----------------------------------------------------------------------------
#
# INPUT
# - TEST_SRC_PACKAGE
#     package of source files, the first element in this list defines the name
#     of the test target (<RELATIVE_TEST_DIR>_<NAME>_<SUFFIX>).
# - TEST_SOLUTION_FOLDER
#     solution folder to place the test target into.
# - TEST_LIBRARIES
#     target link libraries of the test target.
# - TEST_INCLUDE_DIRS
#     target include directories of the test target.
# - TEST_COMPILE_OPTIONS
#     target compile options of the test target.
# - TEST_COMPILE_DEFINITIONS
#     target compile definitions of the test target.
# - TEST_NAME_SUFFIX
#     suffix for the test target (<NAME>_<SUFFIX>). useful for targets of the same
#     source package with different compile options and/or definitions.
#
# OUTPUT
# - OUTPUT_TARGET_NAME
#
# -----------------------------------------------------------------------------
function(add_wet_test TEST_SRC_PACKAGE TEST_SOLUTION_FOLDER TEST_LIBRARIES TEST_INCLUDE_DIRS TEST_COMPILE_OPTIONS TEST_COMPILE_DEFINITIONS TEST_NAME_SUFFIX OUTPUT_TARGET_NAME)
  if(NOT TEST_SRC_PACKAGE)
    # nothing to test without source code
    return()
  endif()
  
  # retrieve the first element of the source code package
  list(GET TEST_SRC_PACKAGE 0 TEST_SRC)
  get_filename_component(TEST_PATH_ABS ${TEST_SRC} DIRECTORY)
  string(REPLACE "${CMAKE_SOURCE_DIR}/" "" TEST_PATH ${TEST_PATH_ABS})
  # get the file name without extension
  get_filename_component(TEST_NAME ${TEST_SRC} NAME_WE)
  # concatenate the relative path and name in an underscore separated identifier
  if(TEST_NAME_SUFFIX)
    string(REPLACE "/" "_" TEST_TARGET_NAME "${TEST_PATH}/${TEST_NAME}/${TEST_NAME_SUFFIX}")
  else()
    string(REPLACE "/" "_" TEST_TARGET_NAME "${TEST_PATH}/${TEST_NAME}")
  endif()
  
  if(TARGET ${TEST_TARGET_NAME})
    # target already exists...
    return()
  endif()
  
  # create an executable with the corresponding source package to test (given by the user)
  add_executable(${TEST_TARGET_NAME} ${TEST_SRC_PACKAGE})
  
  if(TEST_LIBRARIES)
    target_link_libraries(${TEST_TARGET_NAME} PRIVATE ${TEST_LIBRARIES})
  endif()
  
  if(TEST_INCLUDE_DIRS)
    target_include_directories(${TEST_TARGET_NAME} PRIVATE ${TEST_INCLUDE_DIRS})
  endif()
  
  if(TEST_COMPILE_OPTIONS)
    target_compile_options(${TEST_TARGET_NAME} PRIVATE ${TEST_COMPILE_OPTIONS})
  endif()
  
  if(TEST_COMPILE_DEFINITIONS)
    target_compile_definitions(${TEST_TARGET_NAME} PRIVATE ${TEST_COMPILE_DEFINITIONS})
  endif()
  
  # set a variety of target properties
  # - match the relative path in the build tree with the corresponding one in the source tree
  # - put the target into the test solution folder
  set_target_properties(${TEST_TARGET_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${TEST_PATH}
    FOLDER "${TEST_SOLUTION_FOLDER}/${TEST_PATH}"
  )
  
  # add this target as a test in the relative path towards the build tree
  add_test(${TEST_TARGET_NAME} ${TEST_PATH}/${TEST_TARGET_NAME})
  set(${OUTPUT_TARGET_NAME} "${TEST_TARGET_NAME}" PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# filter_source_by_platform_infix
# -----------------------------------------------------------------------------
#
# Works under the assumption of a naming pattern like
# <FILENAME><PLATFORM_INFIX_DIVIDER><PLATFORM_INFIX><EXTENSION>.
#
# INPUT
# - SRC_FILES
#     the folder to glob recursively
# - PLATFORM_INFIX_DIVIDER
#     the divider in front of the infix (e.g. '.' (dot), '_' (underscore), ...)
# - PLATFORM_INFIX
#     the infix of the target platform (e.g. win32, unix, ...)
# - PLATFORM_INFIXES_KNOWN
#     the complete list of infixes used within the source tree
# - (name) OUTPUT_FILES
#
# OUTPUT
# - OUTPUT_FILES
#     the list of files curated by target platform
#
# -----------------------------------------------------------------------------
function(filter_source_by_platform_infix SRC_FILES PLATFORM_INFIX_DIVIDER PLATFORM_INFIX PLATFORM_INFIXES_KNOWN OUTPUT_FILES)
  # algorithm
  # 1) find platform infix introduced by the given source file
  # 2) -> check if this infix is correct for this platform
  # 3) -> check if this infix is a known infix
  # 4) remove source files with 2) = false and 3) = true

  set(FILES_TO_REMOVE)

  foreach(FILE ${SRC_FILES})
    # name without extension would not be enough, as the PLATFORM_INFIX_DIVIDER could be a DOT (.)
    get_filename_component(FILENAME ${FILE} NAME)
    # create a list from string by dividing at PLATFORM_INFIX_DIVIDER or DOT (.)
    string(REGEX REPLACE "[${PLATFORM_INFIX_DIVIDER}]|[.]" ";" FILENAME_LIST ${FILENAME})
    # minimum number of elements of the list so it could contain a platform infix is length > 2
    list(LENGTH FILENAME_LIST FILENAME_LIST_LENGTH)
    if(FILENAME_LIST_LENGTH GREATER 2)
      # last element (length - 1) is the extension, length - 2 is the index of the platform infix
      math(EXPR FILENAME_INFIX_INDEX ${FILENAME_LIST_LENGTH}-2)
      list(GET FILENAME_LIST "${FILENAME_INFIX_INDEX}" FILENAME_INFIX)
      # check for infix recognition is made because of edge cases like 'thread_pool.cpp' with a
	  # platform divider of '_'. The infix 'pool' is not a known platform so this file will not be
	  # removed from the source tree.
      list(FIND PLATFORM_INFIXES_KNOWN "${FILENAME_INFIX}" KNOWN_INFIX_INDEX)
      # iterate over every possible infix of the current platform
      foreach(CURRENT_INFIX ${PLATFORM_INFIX})
        # infix is not for this platform and found on the known infix list
        if(NOT FILENAME_INFIX STREQUAL CURRENT_INFIX AND NOT KNOWN_INFIX_INDEX EQUAL -1)
          list(APPEND FILES_TO_REMOVE ${FILE})
        endif()
      endforeach()
    endif()
  endforeach()
  
  if(FILES_TO_REMOVE)
    list(REMOVE_ITEM SRC_FILES ${FILES_TO_REMOVE})
  endif()
  
  set(${OUTPUT_FILES} ${SRC_FILES} PARENT_SCOPE)
endfunction()

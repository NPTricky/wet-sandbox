# General Purpose

# -----------------------------------------------------------------------------
# get_processor_count
# -----------------------------------------------------------------------------
#
# INPUT
# - (name) OUTPUT_PROCESSOR_COUNT
#
# OUTPUT
# - OUTPUT_PROCESSOR_COUNT
#     number of available processor cores
#
# -----------------------------------------------------------------------------
function(get_processor_count OUTPUT_PROCESSOR_COUNT)
  set(PROCESSOR_COUNT 1) # default
  if(UNIX)
    set(CPUINFO_FILE "/proc/cpuinfo")
    if(EXISTS "${CPUINFO_FILE}")
      file(STRINGS "${CPUINFO_FILE}" PROCESSOR_STRINGS REGEX "^processor.: [0-9]+$")
      list(LENGTH PROCESSOR_STRINGS PROCESSOR_COUNT)
    endif()
  elseif(APPLE)
    find_program(SystemProfiler "system_profiler")
    if(SystemProfiler)
      execute_process(COMMAND ${SystemProfiler} OUTPUT_VARIABLE SYSTEM_INFORMATION)
      string(REGEX REPLACE
        "^.*Total Number Of Cores: ([0-9]+).*$"
        "\\1"
        PROCESSOR_COUNT
        "${SYSTEM_INFORMATION}"
      )
    endif()
  elseif(WIN32)
    set(PROCESSOR_COUNT "$ENV{NUMBER_OF_PROCESSORS}")
  endif()
  message(STATUS "Available Thread(s): ${PROCESSOR_COUNT}")
  set(${OUTPUT_PROCESSOR_COUNT} "${PROCESSOR_COUNT}" PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# check_compiler
# -----------------------------------------------------------------------------
#
# OUTPUT
# - FATAL_ERROR on missing support for c++11
#
# -----------------------------------------------------------------------------
function(check_compiler)
  set(ERROR_MESSAGE "In order to use C++11 features, this library cannot be built using a version of")
  if(${CMAKE_CXX_COMPILER_ID} STREQUAL "MSVC")
    # i.e 18 for MSVC < Visual Studio 2013
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "18")
      message(FATAL_ERROR "${ERROR_MESSAGE} Visual Studio lower than 2013")
    endif()
  elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "3.2")
      message(FATAL_ERROR "${ERROR_MESSAGE} Clang lower than 3.2")
    endif()
  elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7")
      message(FATAL_ERROR "${ERROR_MESSAGE} GCC lower than 4.7")
    endif()
  endif()
endfunction()

# -----------------------------------------------------------------------------
# glob_source_and_group_by_folder
# -----------------------------------------------------------------------------
#
# Not the recommended way of source tree creation but fast and clean, even
# after major code restructuring.
#
# INPUT
# - FOLDER
#     the folder to glob recursively
# - FILE_CATEGORY
#     the solution folder where to put the file hierarchy into
# - FILE_EXTENSIONS
#     the desired file extensions to glob
# - (name) OUTPUT_FILES
#
# OUTPUT
# - OUTPUT_FILES
#     the list of files extracted recursively from the folder
#
# -----------------------------------------------------------------------------
function(glob_source_and_group_by_folder FOLDER FILE_CATEGORY FILE_EXTENSIONS OUTPUT_FILES)
  set(PATH_BASE ${FOLDER})
  file(GLOB_RECURSE ALL_FILES ${FOLDER}/*)

  string(REPLACE ";" "|" FILE_EXTENSION_REGEX "${FILE_EXTENSIONS}")
  set(FILE_LIST)

  foreach(FILE ${ALL_FILES})
    get_filename_component(PARENT_DIR ${FILE} PATH)
    
    # strip path base from the directory of the current file
    string(REPLACE ${PATH_BASE} "" PARENT_DIR_STRIPPED ${PARENT_DIR})
    # change /'s to \\'s (escaped \'s)
    string(REPLACE "/" "\\\\" GROUP "${PARENT_DIR_STRIPPED}")
    
    # matches the '|' separated list of file extensions
    if(${FILE} MATCHES "^.*\\.(${FILE_EXTENSION_REGEX})$")
      set(GROUP "${FILE_CATEGORY}${GROUP}")
      source_group(${GROUP} FILES ${FILE})
      list(APPEND FILE_LIST ${FILE})
    endif()
  endforeach()

  set(${OUTPUT_FILES} ${FILE_LIST} PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# print_cmake_variables
# -----------------------------------------------------------------------------
function(print_cmake_variables)
  # this function prints every available cmake variable
  get_cmake_property(VARIABLE_NAMES VARIABLES)
  message("*:")
  foreach(VARIABLE_NAME ${VARIABLE_NAMES})
    message(STATUS " - ${VARIABLE_NAME}: ${${VARIABLE_NAME}}")
  endforeach()
endfunction()

# -----------------------------------------------------------------------------
# print_cxx_known_features
# -----------------------------------------------------------------------------
function(print_cxx_known_features)
  # this function prints every available c++ feature (e.g. cxx_variadic_templates)
  message("CMAKE_CXX_KNOWN_FEATURES:")
  foreach(FEATURE ${CMAKE_CXX_KNOWN_FEATURES})
    message(" - ${FEATURE}")
  endforeach()
endfunction()

# -----------------------------------------------------------------------------
# check_configuration_generator
# -----------------------------------------------------------------------------
function(check_configuration_generator)
  if(NOT CMAKE_CONFIGURATION_TYPES) # single-configuration generator...
    if(NOT CMAKE_BUILD_TYPE) # ...with no build type given
      set(CMAKE_BUILD_TYPES "Debug;Release;RelWithDebInfo;MinSizeRel" CACHE INTERNAL "Possible Build-Types are Debug, Release, RelWithDebInfo or MinSizeRel.")
	  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_BUILD_TYPES})
    endif()
    message(STATUS "Single-Configuration Generator:")
	message(STATUS " - CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  else()
    message(STATUS "Multi-Configuration Generator:")
	message(STATUS " - CMAKE_CONFIGURATION_TYPES: ${CMAKE_CONFIGURATION_TYPES}")
  endif()
endfunction()

# -----------------------------------------------------------------------------
# check_source_build
# -----------------------------------------------------------------------------
#
# OUTPUT
# - FATAL_ERROR on in-source build
#
# -----------------------------------------------------------------------------
function(check_source_build)
  if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-Source builds are forbidden. Please create a new build directory (e.g. ${CMAKE_SOURCE_DIR}-build) and run CMake from there. You may need to remove CMakeCache.txt.")
  endif()
endfunction()

# -----------------------------------------------------------------------------
# bool_translate
# -----------------------------------------------------------------------------
#
# INPUT
# - INPUT_BOOL
#     a valid cmake boolean value
# - INPUT_TRUE
#     desired translation of true
# - INPUT_FALSE
#     desired translation of false
# - (name) OUTPUT_BOOL
#
# OUTPUT
# - OUTPUT_STRING
#     a string representing the boolean value
#
# -----------------------------------------------------------------------------
function(bool_translate INPUT_BOOL INPUT_TRUE INPUT_FALSE OUTPUT_STRING)
  if(${INPUT_BOOL})
    set(TRANSLATION "${INPUT_TRUE}")
  else()
    set(TRANSLATION "${INPUT_FALSE}")
  endif()
  set(${OUTPUT_STRING} "${TRANSLATION}" PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# string_first_char_to_upper_case
# -----------------------------------------------------------------------------
#
# INPUT
# - INPUT_STRING
#     string to make first character upper case
# - (name) OUTPUT_STRING
#
# OUTPUT
# - OUTPUT_STRING
#     string with first character in upper case
#
# -----------------------------------------------------------------------------
function(string_first_char_to_upper_case INPUT_STRING OUTPUT_STRING)
  string(SUBSTRING "${INPUT_STRING}" 0  1 FIRST)
  string(SUBSTRING "${INPUT_STRING}" 1 -1 TAIL )
  string(TOUPPER "${FIRST}" FIRST)
  set(${OUTPUT_STRING} "${FIRST}${TAIL}" PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# string_underscore_to_camel_case
# -----------------------------------------------------------------------------
#
# INPUT
# - INPUT_STRING
#     underscore separated string about to be in camel case
# - (name) OUTPUT_STRING
#
# OUTPUT
# - OUTPUT_STRING
#     camel case string
#
# -----------------------------------------------------------------------------
function(string_underscore_to_camel_case INPUT_STRING OUTPUT_STRING)
  string(REPLACE "_" ";" INPUT_STRING_LIST ${INPUT_STRING})
  foreach(SUBSTRING ${INPUT_STRING_LIST})
    string_first_char_to_upper_case(SUBSTRING SUBSTRING_UPPER)
    set(CAMEL_CASE ${CAMEL_CASE}${SUBSTRING_UPPER})
  endforeach()
  set(${OUTPUT_STRING} ${CAMEL_CASE} PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# list_to_string
# -----------------------------------------------------------------------------
#
# INPUT
# - ITEM_LIST
#     the cmake list to stringify
# - SEPARATOR
#     the string separator desired in the output string
# - (name) OUTPUT
#
# OUTPUT
# - OUTPUT
#     the cmake list as a string with the given separator
#
# -----------------------------------------------------------------------------
function(list_to_string ITEM_LIST SEPARATOR OUTPUT)
  # split the string at separator symbols
  string (REGEX REPLACE "([^\\]|^);" "\\1${SEPARATOR}" _TMP_STR "${ITEM_LIST}")
  # fix escape characters
  string (REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}")
  set (${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

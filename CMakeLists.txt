cmake_minimum_required(VERSION 3.1.0)

project(wet-sandbox)

# guarantee the 3.1.0 feature set even in later cmake releases
if(CMAKE_VERSION VERSION_GREATER 3.1.0)
  cmake_policy(VERSION 3.1.0)
endif()

# search modules in project directory first
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# -----------------------------------------------------------------------------
# Include CMake Macros & Functions
# -----------------------------------------------------------------------------

include(Utility) # general utility
include(WetSandbox)

# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------

check_compiler() # enforce c++11 support
check_source_build() # check for in-source build and stop this stray sheeplet
check_configuration_generator() # provide sane options for a single configuration generator

# cmake related
set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_DEBUG_POSTFIX "d") # common library & executable debug postfix
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON) # internal include priority

# project related
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 0)
set(PROJECT_VERSION_PATCH 0)
set(PROJECT_VERSION_TWEAK 0)
set(PROJECT_CONTACT "GitHub User <@NPTricky>")
set(PROJECT_HOMEPAGE "https://github.com/NPTricky/wet-sandbox")
set(PROJECT_DESCRIPTION "It's nothing more than a wet sandbox.")

# bit variable
set(BIT 32) # BIT 32 = MATCHES "4"
if(${CMAKE_SIZEOF_VOID_P} MATCHES "8") # BIT 64
  set(BIT 64)
  set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS ON)
endif()

# -----------------------------------------------------------------------------
# Build Settings
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Settings
# -----------------------------------------------------------------------------

option(CONFIG_USE_SOLUTION_FOLDERS "Group Build Targets (Visual Studio, ...)" ON)

# property configuration
set_property(GLOBAL PROPERTY USE_FOLDERS ${CONFIG_USE_SOLUTION_FOLDERS}) 

# -----------------------------------------------------------------------------
# Third Party Libraries
# -----------------------------------------------------------------------------

include(ExternalProject)
set_directory_properties(PROPERTIES EP_PREFIX ${CMAKE_BINARY_DIR}/ext)


# thread library
find_package(Threads REQUIRED)

# googletest
ExternalProject_Add(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG a9b73f8139a92315f37e48a3ff3d43e3929055bc
  TIMEOUT 10
  # configure step
  # Force separate output paths for debug and release builds to allow easy
  # identification of correct lib in subsequent TARGET_LINK_LIBRARIES commands
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG:PATH=DebugLibs
             -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE:PATH=ReleaseLibs
             -Dgtest_force_shared_crt=ON
  # install step (deactivate)
  INSTALL_COMMAND ""
  # output logging
  LOG_DOWNLOAD ON
  LOG_UPDATE ON
  LOG_CONFIGURE ON
  LOG_BUILD ON
  LOG_TEST ON
  LOG_INSTALL ON
)

# -----------------------------------------------------------------------------
# Source
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Testing
# -----------------------------------------------------------------------------

if(BUILD_TEST)
  add_subdirectory(test)
endif()

# -----------------------------------------------------------------------------
# Documentation
# -----------------------------------------------------------------------------

if(BUILD_DOC)
  add_subdirectory(doc)
endif()

# -----------------------------------------------------------------------------
# Examples
# -----------------------------------------------------------------------------

if(BUILD_EXAMPLE)
  add_subdirectory(example)
endif()

# -----------------------------------------------------------------------------
# Packaging
# -----------------------------------------------------------------------------

if(BUILD_PACKAGE)
  add_subdirectory(pkg)
endif()

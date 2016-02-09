# -----------------------------------------------------------------------------
# eigen
# -----------------------------------------------------------------------------

set(TARGET_NAME "eigen")
set(TARGET_LIBRARY_DIR "${PROJECT_SOURCE_DIR}/ext/${TARGET_NAME}")
set(TARGET_INSTALL_DIR "include/${TARGET_NAME}")

if(TARGET_LIBRARY_DIR)
  
  add_library(${TARGET_NAME} INTERFACE)
  target_include_directories(${TARGET_NAME} INTERFACE
    $<BUILD_INTERFACE:${TARGET_LIBRARY_DIR}>
    $<INSTALL_INTERFACE:${TARGET_INSTALL_DIR}>
  )
  target_compile_definitions(${TARGET_NAME} INTERFACE "EIGEN_NO_DEBUG")
  
  #EIGEN_USE_BLAS
  #EIGEN_USE_LAPACKE_STRICT
  
endif()

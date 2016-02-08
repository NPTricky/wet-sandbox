# -----------------------------------------------------------------------------
# Documentation - Configuration
# -----------------------------------------------------------------------------

set(DOC_SOLUTION_FOLDER "${CMAKE_PROJECT_NAME}_DOC")
set(DOC_TARGET_NAME "doc_builder")

# -----------------------------------------------------------------------------
# Documentation
# -----------------------------------------------------------------------------

find_package(Doxygen)

if(DOXYGEN_FOUND)
  # Options
  option(DOXYGEN_BUILD_XML "Build Documentation (XML)" OFF)
  option(DOXYGEN_BUILD_MAN "Build Documentation (Man)" OFF)
  option(DOXYGEN_BUILD_RTF "Build Documentation (RTF)" OFF)
  option(DOXYGEN_BUILD_PDF "Build Documentation (PDF)" OFF)
  option(DOXYGEN_BUILD_HTML "Build Documentation (HTML)" ON)
  option(DOXYGEN_GRAPH_VISUALIZATION "Use Dot Tool (Graph Visualization)" OFF)
  option(DOXYGEN_USE_PDFLATEX "Use PDFLATEX for PDF" ON)
  mark_as_advanced(
    DOXYGEN_BUILD_MAN
    DOXYGEN_BUILD_RTF
    DOXYGEN_BUILD_XML
  )
  
  # PDF Documentation - Default
  set(DOXYGEN_BUILD_PDF_CONFIG "NO")
  set(DOXYGEN_USE_PDFLATEX_CONFIG "NO")
  # PDF Documentation
  if(DOXYGEN_BUILD_PDF)
    find_package(LATEX)
    if(LATEX_COMPILER AND MAKEINDEX_COMPILER)
      if(DOXYGEN_USE_PDFLATEX AND PDFLATEX_COMPILER)
        set(DOXYGEN_BUILD_PDF_CONFIG "YES")
        set(DOXYGEN_USE_PDFLATEX_CONFIG "YES")
      else() # NOT DOXYGEN_USE_PDFLATEX or NOT PDFLATEX_COMPILER
        if(GHOSTSCRIPT_BINARY_PATH)
          set(DOXYGEN_BUILD_PDF_CONFIG "YES")
        else()
          message(STATUS "Requirement(s) BUILD_PDF: GHOSTSCRIPT or PDFLATEX!")
        endif()
      endif()
    else() # NOT LATEX_COMPILER or NOT MAKEINDEX_COMPILER
      message(STATUS "Requirement(s) DOXYGEN_BUILD_PDF: LATEX_COMPILER and MAKEINDEX_COMPILER!")
    endif()
  endif()
  
  # Graph Visualization - Default
  set(DOXYGEN_GRAPH_VISUALIZATION_CONFIG "NO")
  # Graph Visualization
  if(DOXYGEN_GRAPH_VISUALIZATION)
    # Dot
    if(DOXYGEN_DOT_EXECUTABLE)
      set(DOXYGEN_GRAPH_VISUALIZATION_CONFIG "YES")
    else() # NOT DOXYGEN_DOT_EXECUTABLE
      message(STATUS "Requirement(s) DOXYGEN_GRAPH_VISUALIZATION: DOXYGEN_DOT_EXECUTABLE!")
    endif()
    # mscgen
    find_program(DOXYGEN_MSCGEN_EXECUTABLE
      NAMES mscgen
      DOC "Parser for Message Sequence Chart Descriptions"
    )
    if(DOXYGEN_MSCGEN_EXECUTABLE)
      get_filename_component(DOXYGEN_MSCGEN_PATH "${DOXYGEN_MSCGEN_EXECUTABLE}" DIRECTORY)
    else()
      message(STATUS "Optional Requirement(s) DOXYGEN_GRAPH_VISUALIZATION: DOXYGEN_MSCGEN_EXECUTABLE")
    endif()
    # Dia
    find_program(DOXYGEN_DIA_EXECUTABLE
      NAMES dia
      DOC "Drawing Software for Structured Diagrams"
    )
    if(DOXYGEN_DIA_EXECUTABLE)
      get_filename_component(DOXYGEN_DIA_PATH "${DOXYGEN_DIA_EXECUTABLE}" DIRECTORY)
    else()
      message(STATUS "Optional Requirement(s) DOXYGEN_GRAPH_VISUALIZATION: DOXYGEN_DIA_EXECUTABLE")
    endif()
  endif()
  
  # Other Documentation
  list(APPEND DOCUMENTATION_CONFIG_LIST
    "DOXYGEN_BUILD_XML" "DOXYGEN_BUILD_MAN" "DOXYGEN_BUILD_RTF" "DOXYGEN_BUILD_HTML"
  )
  foreach(ELEMENT ${DOCUMENTATION_CONFIG_LIST})
    bool_translate(${ELEMENT} "YES" "NO" ELEMENT_TRANSLATION)
    set(${ELEMENT}_CONFIG "${ELEMENT_TRANSLATION}")
  endforeach()
  
  # Apply...
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in
    ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY IMMEDIATE
  )
  
  # Convenience Build Target
  if(DOXYGEN_BUILD_XML OR
     DOXYGEN_BUILD_MAN OR
     DOXYGEN_BUILD_RTF OR
     DOXYGEN_BUILD_PDF OR
     DOXYGEN_BUILD_HTML)
    add_custom_target(${DOC_TARGET_NAME}
      COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
      SOURCES ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
      COMMENT "Generate Doxygen Documentation"
      VERBATIM
    )
    set_target_properties(${DOC_TARGET_NAME} PROPERTIES
      FOLDER "${DOC_SOLUTION_FOLDER}"
    )
  endif()
endif()

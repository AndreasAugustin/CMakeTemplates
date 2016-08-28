################################################################################
#
# Template for cmake config files.
#
# Required variables:
# PROJECT_NAME The name of the project.
#
# Optional variables:
# @PROJECT_NAME@_CMAKE_DEBUG If set to on, some debug output will be enabled.
#
# Project needs to export targets to @PROJECT_NAME@Targets.cmake
#
################################################################################
#
# @License: MIT
# @Author: Andreas Augustin
# @Email: andy.augustin@t-online.de
#
################################################################################


if(NOT PROJECT_NAME)
    message(FATAL_ERROR "[${CMAKE_CURRENT_LIST_DIR}:${CMAKE_CURRENT_LIST_LINE}] "
            "${PROJECT_NAME} project name not set")
endif()

set(_CMAKE_CONFIG_TEMPLATE_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
mark_as_advanced(
        _CMAKE_CONFIG_TEMPLATE_LIST_DIR)

#############
# Adds cmake config files.
#   PROJECT_VERSION The version of the project MAJOR.MINOR.PATCH.
#   PROJECT_EXPORT_TARGETS The targets to export.
############
function(add_cmake_config_files PROJECT_VERSION PROJECT_EXPORT_TARGETS)

    if(${PROJECT_NAME}_CMAKE_DEBUG)
        message(STATUS "[${CMAKE_CURRENT_LIST_DIR}:${CMAKE_CURRENT_LIST_LINE}] "
                "${PROJECT_NAME} creating cmake config file")
    endif()

    if(NOT INSTALL_CMAKE_DIR)
        if(WIN32 AND NOT CYGWIN)
            set(INSTALL_CMAKE_DIR CMake)
        else()
            set(INSTALL_CMAKE_DIR lib/CMake/${PROJECT_NAME})
        endif()
    endif()

    if(NOT INSTALL_INCLUDE_DIR)
        set(INSTALL_INCLUDE_DIR include)
    endif()

    # Add all targets to the build-tree export set
    export(TARGETS ${PROJECT_EXPORT_TARGETS}
            FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PROJECT_NAME})

    # Make relative paths absolute
    foreach(p INCLUDE CMAKE)
        set(var INSTALL_${p}_DIR)
        if(NOT IS_ABSOLUTE "${${var}}")
            set(_${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
        endif()
        mark_as_advanced(_${var})
    endforeach()

    # Calculate relative path between install cmake dir and install include dir
    file(RELATIVE_PATH REL_INCLUDE_DIR "${_INSTALL_CMAKE_DIR}"
            "${_INSTALL_INCLUDE_DIR}")

    ######################## create lists with executables and libs ############

    set(_LIBRARY_TARGETS "")
    set(_EXECUTABLE_TARGETS "")

    mark_as_advanced(
            _LIBRARY_TARGETS
            _EXECUTABLE_TARGETS)

    foreach(tar "${PROJECT_EXPORT_TARGETS}")
        get_property(_TAR_TARGET_TYPE TARGET ${tar} PROPERTY TYPE)
        if(${_TAR_TARGET_TYPE} STREQUAL "EXECUTABLE")
            list(APPEND _EXECUTABLE_TARGETS ${tar})
        else()
            list(APPEND _LIBRARY_TARGETS ${tar})
        endif()
    endforeach ()

    ######################## create files ######################################

    # Config for build tree
    set(CONF_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}")
    configure_file(${_CMAKE_CONFIG_TEMPLATE_LIST_DIR}/templateConfig.cmake.in
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake" @ONLY)

    # Config for install tree
    set(CONF_INCLUDE_DIRS "${REL_INCLUDE_DIR}")
    configure_file(${_CMAKE_CONFIG_TEMPLATE_LIST_DIR}/templateConfig.cmake.in
            "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}Config.cmake" @ONLY)

    # Version
    configure_file(${_CMAKE_CONFIG_TEMPLATE_LIST_DIR}/templateConfigVersion.cmake.in
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" @ONLY)

endfunction()

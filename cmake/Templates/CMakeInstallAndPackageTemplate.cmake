################################################################################
#
# Template for installing and packaging the project.
#
# Required variables:
# PROJECT_NAME The name of the project.
#
# Optional variables:
# @PROJECT_NAME@_CMAKE_DEBUG If set to on, some debug output will be enabled.
#
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

set(_CMAKE_INSTALL_AND_PACKAGE_TEMPLATE_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
mark_as_advanced(
        _CMAKE_INSTALL_AND_PACKAGE_TEMPLATE_LIST_DIR)

#############
# Adds install instructions for the targets.
#   TARGET_TO_INSTALL The target.
#   PUBLIC_HDRS The public headers. If none present, use "".
############
function(install_target TARGET_TO_INSTALL PUBLIC_HDRS)

    if(NOT TARGET ${TARGET_TO_INSTALL})
        message(FATAL_ERROR "[${_CMAKE_INSTALL_AND_PACKAGE_TEMPLATE_LIST_DIR}:${CMAKE_CURRENT_LIST_LINE}] "
                "${PROJECT_NAME} The given parameter is not a target")
    endif()

    if(NOT INSTALL_INCLUDE_DIR)
        set(INSTALL_INCLUDE_DIR include)
    endif()

    if(NOT INSTALL_BIN_DIR)
        set(INSTALL_BIN_DIR bin)
    endif()

    if(NOT INSTALL_LIB_DIR)
        set(INSTALL_LIB_DIR lib)
    endif()

    set_target_properties(${TARGET_TO_INSTALL}
            PROPERTIES PUBLIC_HEADER "${PUBLIC_HDRS}")

    install(TARGETS ${TARGET_TO_INSTALL}
            EXPORT ${PROJECT_NAME}Targets
            RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT bin
            ARCHIVE DESTINATION "${INSTALL_LIB_DIR}" COMPONENT lib
            LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT shlib
            PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}/${PROJECT_NAME}")

endfunction()

#############
# Install config files
############
function(install_config_file)

    if(NOT INSTALL_CMAKE_DIR)
        if(WIN32 AND NOT CYGWIN)
            set(INSTALL_CMAKE_DIR CMake)
        else()
            set(INSTALL_CMAKE_DIR lib/CMake/${PROJECT_NAME})
        endif()
    endif()

    install(EXPORT ${PROJECT_NAME}Targets DESTINATION ${INSTALL_CMAKE_DIR})
    install(FILES
            "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}Config.cmake"
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
            DESTINATION "${INSTALL_CMAKE_DIR}" COMPONENT dev)
endfunction()


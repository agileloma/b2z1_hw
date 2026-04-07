cmake_minimum_required(VERSION 3.16)
project(b2z1_hw LANGUAGES CXX)

#
# Global build settings
#
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#
# Helper utilities
#

# Normalize host arch to the two supported vendor folders.
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
  set(_default_unitree_arch "x86_64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
  set(_default_unitree_arch "aarch64")
else()
  message(FATAL_ERROR "Unsupported host architecture '${CMAKE_SYSTEM_PROCESSOR}'. Set -DUNITREE_SDK2_ARCH=x86_64 or aarch64.")
endif()

function(assert_supported_arch var_name)
  if(NOT "${${var_name}}" STREQUAL "x86_64" AND NOT "${${var_name}}" STREQUAL "aarch64")
    message(FATAL_ERROR "${var_name} must be 'x86_64' or 'aarch64', got '${${var_name}}'.")
  endif()
endfunction()

function(assert_vendored_package package_name package_prefix package_config)
  if(NOT EXISTS "${package_prefix}")
    message(FATAL_ERROR "Vendored ${package_name} prefix not found: ${package_prefix}")
  endif()

  if(NOT EXISTS "${package_config}")
    message(FATAL_ERROR "${package_name} config not found at ${package_config}. Ensure ${package_name} vendor files are populated.")
  endif()
endfunction()

function(set_vendored_rpath target_name library_dir)
  # Allow runtime resolution from vendored SDK without environment variables.
  set_target_properties("${target_name}"
    PROPERTIES
      BUILD_RPATH "${library_dir}"
      INSTALL_RPATH "${library_dir}"
  )
endfunction()

#
# unitree_sdk2 target
#

set(UNITREE_SDK2_ARCH "${_default_unitree_arch}" CACHE STRING "Architecture of vendored unitree_sdk2 (x86_64 or aarch64)")
set_property(CACHE UNITREE_SDK2_ARCH PROPERTY STRINGS x86_64 aarch64)
assert_supported_arch(UNITREE_SDK2_ARCH)

set(UNITREE_SDK2_PREFIX "${CMAKE_SOURCE_DIR}/external/unitree_sdk2/${UNITREE_SDK2_ARCH}")
set(UNITREE_SDK2_CONFIG "${UNITREE_SDK2_PREFIX}/lib/cmake/unitree_sdk2/unitree_sdk2Config.cmake")
set(UNITREE_SDK2_LIBDIR "${UNITREE_SDK2_PREFIX}/lib")

assert_vendored_package("unitree_sdk2" "${UNITREE_SDK2_PREFIX}" "${UNITREE_SDK2_CONFIG}")
list(PREPEND CMAKE_PREFIX_PATH "${UNITREE_SDK2_PREFIX}")
find_package(unitree_sdk2 CONFIG REQUIRED)

add_executable(b2_stand_example
  example/b2_stand_example.cpp
)
target_link_libraries(b2_stand_example
  PRIVATE
    unitree_sdk2
)
set_vendored_rpath(b2_stand_example "${UNITREE_SDK2_LIBDIR}")

#
# z1_sdk target
#

set(Z1_SDK_ARCH "${_default_unitree_arch}" CACHE STRING "Architecture of vendored z1_sdk (x86_64 or aarch64)")
set_property(CACHE Z1_SDK_ARCH PROPERTY STRINGS x86_64 aarch64)
assert_supported_arch(Z1_SDK_ARCH)

set(Z1_SDK_PREFIX "${CMAKE_SOURCE_DIR}/external/z1_sdk/${Z1_SDK_ARCH}" CACHE PATH "Prefix path of vendored z1_sdk")
set(Z1_SDK_CONFIG "${Z1_SDK_PREFIX}/lib/cmake/z1_sdk/z1_sdkConfig.cmake")

assert_vendored_package("z1_sdk" "${Z1_SDK_PREFIX}" "${Z1_SDK_CONFIG}")
list(PREPEND CMAKE_PREFIX_PATH "${Z1_SDK_PREFIX}")
find_package(z1_sdk CONFIG REQUIRED)
message(STATUS "z1_sdk enabled from ${Z1_SDK_PREFIX}")

add_executable(z1_lowcmd_development
  example/z1_lowcmd_development.cpp
)
target_link_libraries(z1_lowcmd_development
  PRIVATE
    z1_sdk::z1_sdk
)
set_vendored_rpath(z1_lowcmd_development "${Z1_SDK_PREFIX}/lib")

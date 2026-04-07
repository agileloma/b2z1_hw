cmake_minimum_required(VERSION 3.16)
project(b2z1_hw LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(ENABLE_Z1_SDK OFF CACHE BOOL "Enable optional vendored z1_sdk discovery")

# Normalize host arch to the two supported vendor folders.
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
  set(_default_unitree_arch "x86_64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
  set(_default_unitree_arch "aarch64")
else()
  message(FATAL_ERROR "Unsupported host architecture '${CMAKE_SYSTEM_PROCESSOR}'. Set -DUNITREE_SDK2_ARCH=x86_64 or aarch64.")
endif()

set(UNITREE_SDK2_ARCH "${_default_unitree_arch}" CACHE STRING "Architecture of vendored unitree_sdk2 (x86_64 or aarch64)")
set_property(CACHE UNITREE_SDK2_ARCH PROPERTY STRINGS x86_64 aarch64)

if(NOT UNITREE_SDK2_ARCH STREQUAL "x86_64" AND NOT UNITREE_SDK2_ARCH STREQUAL "aarch64")
  message(FATAL_ERROR "UNITREE_SDK2_ARCH must be 'x86_64' or 'aarch64', got '${UNITREE_SDK2_ARCH}'.")
endif()

set(UNITREE_SDK2_PREFIX "${CMAKE_SOURCE_DIR}/external/unitree_sdk2/${UNITREE_SDK2_ARCH}")
set(UNITREE_SDK2_CONFIG "${UNITREE_SDK2_PREFIX}/lib/cmake/unitree_sdk2/unitree_sdk2Config.cmake")
set(UNITREE_SDK2_LIBDIR "${UNITREE_SDK2_PREFIX}/lib")

if(NOT EXISTS "${UNITREE_SDK2_PREFIX}")
  message(FATAL_ERROR "Vendored unitree_sdk2 prefix not found: ${UNITREE_SDK2_PREFIX}")
endif()

if(NOT EXISTS "${UNITREE_SDK2_CONFIG}")
  message(FATAL_ERROR "unitree_sdk2Config.cmake not found at ${UNITREE_SDK2_CONFIG}. Ensure external/unitree_sdk2/${UNITREE_SDK2_ARCH} is populated.")
endif()

list(PREPEND CMAKE_PREFIX_PATH "${UNITREE_SDK2_PREFIX}")
find_package(unitree_sdk2 CONFIG REQUIRED)

add_executable(b2_stand_example 
  example/b2_stand_example.cpp
)
target_link_libraries(b2_stand_example 
  PRIVATE 
    unitree_sdk2
)
# Allow runtime resolution of libddsc/libddscxx from vendored SDK without env vars.
set_target_properties(b2_stand_example 
  PROPERTIES
    BUILD_RPATH "${UNITREE_SDK2_LIBDIR}"
    INSTALL_RPATH "${UNITREE_SDK2_LIBDIR}"
)

if(ENABLE_Z1_SDK)
  set(Z1_SDK_ARCH "${_default_unitree_arch}" CACHE STRING "Architecture of vendored z1_sdk (x86_64 or aarch64)")
  set_property(CACHE Z1_SDK_ARCH PROPERTY STRINGS x86_64 aarch64)
  if(NOT Z1_SDK_ARCH STREQUAL "x86_64" AND NOT Z1_SDK_ARCH STREQUAL "aarch64")
    message(FATAL_ERROR "Z1_SDK_ARCH must be 'x86_64' or 'aarch64', got '${Z1_SDK_ARCH}'.")
  endif()

  set(Z1_SDK_PREFIX "${CMAKE_SOURCE_DIR}/external/z1_sdk/${Z1_SDK_ARCH}" CACHE PATH "Prefix path of vendored z1_sdk")
  set(Z1_SDK_CONFIG "${Z1_SDK_PREFIX}/lib/cmake/z1_sdk/z1_sdkConfig.cmake")

  if(NOT EXISTS "${Z1_SDK_PREFIX}")
    message(FATAL_ERROR "Vendored z1_sdk prefix not found: ${Z1_SDK_PREFIX}")
  endif()

  if(NOT EXISTS "${Z1_SDK_CONFIG}")
    message(FATAL_ERROR "z1_sdkConfig.cmake not found at ${Z1_SDK_CONFIG}. Ensure external/z1_sdk/${Z1_SDK_ARCH} is populated.")
  endif()

  list(PREPEND CMAKE_PREFIX_PATH "${Z1_SDK_PREFIX}")
  find_package(z1_sdk CONFIG REQUIRED)
  message(STATUS "z1_sdk enabled from ${Z1_SDK_PREFIX}")
endif()

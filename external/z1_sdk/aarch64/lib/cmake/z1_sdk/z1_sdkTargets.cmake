if(NOT TARGET z1_sdk::z1_sdk)
  add_library(z1_sdk::z1_sdk SHARED IMPORTED GLOBAL)
  get_filename_component(_z1_import_prefix "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
  get_filename_component(_z1_import_prefix "${_z1_import_prefix}" DIRECTORY)
  get_filename_component(_z1_import_prefix "${_z1_import_prefix}" DIRECTORY)

  set_target_properties(z1_sdk::z1_sdk PROPERTIES
    IMPORTED_LOCATION "${_z1_import_prefix}/lib/libZ1_SDK_aarch64.so"
    INTERFACE_INCLUDE_DIRECTORIES "${_z1_import_prefix}/include"
  )

  unset(_z1_import_prefix)
endif()

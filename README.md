# b2z1_hw

## Build `b2_stand_example` with vendored `unitree_sdk2`

Default (host arch autodetected):

```bash
cmake -S . -B build
cmake --build build -j
```

Override architecture (for example, configure against aarch64 vendored SDK):

```bash
cmake -S . -B build-aarch64 -DUNITREE_SDK2_ARCH=aarch64
```

## Run

```bash
./build/b2_stand_example <network_interface>
```

Example:

```bash
./build/b2_stand_example lo
```

The executable embeds RPATH to `external/unitree_sdk2/<arch>/lib`, so `LD_LIBRARY_PATH` is not required.

## Vendored `z1_sdk`

Vendored from:

- Repository: `https://github.com/unitreerobotics/z1_sdk` (branch `master`)
- Pinned commit: `f1af2b42f2a39a5010946e049ad3fe324e2e6f06`

Layout:

- `external/z1_sdk/x86_64/{include,lib}`
- `external/z1_sdk/aarch64/{include,lib}`

Both architectures include local CMake package files under:

- `external/z1_sdk/<arch>/lib/cmake/z1_sdk`

so consumers can use:

```cmake
find_package(z1_sdk CONFIG REQUIRED)
target_link_libraries(<your_target> PRIVATE z1_sdk::z1_sdk)
```

To enable z1_sdk discovery from this project's root CMake:

```bash
cmake -S . -B build-z1 -DENABLE_Z1_SDK=ON -DZ1_SDK_ARCH=x86_64
```

This also builds:

- `z1_lowcmd_development` from `example/lowcmd_development.cpp`

Build and run:

```bash
cmake -S . -B build-z1 -DENABLE_Z1_SDK=ON -DZ1_SDK_ARCH=x86_64
cmake --build build-z1 -j
./build-z1/z1_lowcmd_development
```

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

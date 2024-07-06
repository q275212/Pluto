mkdir -p build
cmake -G Ninja -S . -B build \
      -DCMAKE_C_COMPILER="gcc" \
      -DCMAKE_CXX_COMPILER="g++" \
      -DLLVM_TARGETS_TO_BUILD="X86;AArch64"
      -DCMAKE_INSTALL_PREFIX="install" \
      -DCMAKE_BUILD_TYPE=Release
ninja -j`nproc` -C build install

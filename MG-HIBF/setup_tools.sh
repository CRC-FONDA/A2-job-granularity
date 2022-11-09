mkdir tools
cd tools
git clone --recurse-submodules https://github.com/seqan/raptor
cd raptor
mkdir build
cd build
cmake .. -DCMAKE_CXX_COMPILER=g++-11
make
cd ../..
git clone https://github.com/feldroop/query-distributor
cd query-distributor
cargo build --target-dir target --release

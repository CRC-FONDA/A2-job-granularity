mkdir tools
cd tools
git clone --recurse-submodules https://github.com/seqan/raptor
cd raptor
mkdir build
cd build
cmake ../raptor -DCMAKE_CXX_COMPILER=g++-11
make
cd ../..
git clone https://github.com/feldroop/query_distributor
cd query_distributor
cargo build --target-dir target --release

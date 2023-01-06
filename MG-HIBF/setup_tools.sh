mkdir tools
cd tools
git clone --recurse-submodules https://github.com/seqan/raptor
cd raptor
mkdir build
cd build
cmake .. -DCMAKE_CXX_COMPILER=/home/felid99/gcc/gcc-11.3.0/bin/g++-11.3.0 -DCMAKE_C_COMPILER=/home/felid99/gcc/gcc-11.3.0/bin/gcc-11.3.0
make
cd ../..
git clone https://github.com/feldroop/query-distributor
cd query-distributor
cargo build --target-dir target --release

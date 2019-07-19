# Sample apps for analyzing facial emotion using Affectiva's Automotive SDK for Linux
###frame-detector-webcam-demo

This sample demonstrates use of the [FrameDetector class](https://auto.affectiva.com/docs/vision-create-detector), getting its input from a webcam. It analyzes received frames and displays the results on screen.

After building, run the command `./frame-detector-webcam-demo --help` for information on its command line options.

---

###frame-detector-video-demo

This sample demonstrates use of the [FrameDetector class](https://auto.affectiva.com/docs/vision-create-detector), getting its input from a video file. It analyzes received frames and displays the results on screen.

After building, run the command `./frame-detector-video-demo --help` for information on its command line options.

---

## Dependencies

#### Affectiva Vision library

The Vision Library is packaged with the Automotive SDK, which is available upon request. To get access, please [contact us](https://auto.affectiva.com/).

#### Additional Dependencies

Install additional dependencies with the following command:  
Ubuntu:`$ sudo apt-get install -y build-essential libopencv-dev cmake libgtk2.0-dev pkg-config libjpeg-dev libpng-dev libtiff-dev libjasper-dev libavformat-dev libavcodec-dev libswscale-dev`

[Click here](#ubuntu-18) for instructions on building sample apps for Ubuntu 18.

[Click here](#ubuntu-16) for instruction on building sample apps for Ubuntu 16. 

## Ubuntu 18  

### Boost
Install boost directly from the package manager with the following command:   

Ubuntu: `$ sudo apt-get install -y libboost-dev libboost-filesystem1.65-dev libboost-program-options1.65-dev libboost-system1.65-dev`

### OpenCV  
We do not recommend running the sample apps with opencv 3.2.0 from the package manager. Instead, you must build opencv 2.4.13 from source. Other opencv versions 2.4.** may work but we recommend 2.4.13 as a tested depedency for the sample apps on Ubuntu 18.

Fetch the OpenCV source from github and checkout the 2.4.13 branch with the following commands:

`$ git clone https://github.com/opencv/opencv.git` <br/>
`$ git checkout 2.4.13` 

To make OpenCV 2.4.13 compatible with gcc7, change line 67 in the file `OpenCVDetectCXXCompiler.cmake`   
from **-dumpversion** to **-dumpfullversion**. The file can be found at /path/to/opencv/cmake.  

### Building OpenCV 2.4.13 with CMake

```
cd opencv
mkdir build
cd build

CMAKE_ARGS="-D WITH_FFMPEG=ON \
-D BUILD_TESTS=OFF \ 
-D BUILD_PERF_TESTS=OFF \ 
-D CMAKE_BUILD_TYPE=RELEASE \ 
-D ENABLE_PRECOMPILED_HEADERS=OFF \
-D CMAKE_INSTALL_PREFIX=/path/to/install"

cmake $CMAKE_ARGS ../
make -j4 install 
```
----
### Building Samples with CMake

Specify the the following CMake variables to identify the locations of various dependencies:

- **AFFECTIVA_SDK_DIR**: path to the folder where the Automotive SDK is installed
- **BOOST_ROOT** path to the Boost src tree
- **OpenCV_DIR** path to the opencv src tree 

#### Linux (x86_64, aarch64)

For building under Linux, type the following command:

`$ cmake . -DCMAKE_BUILD_TYPE=[Release,Debug] <other args>`

Example script (replace directories starting with `/path/to` as appropriate):  
```
# create a build directory
mkdir vision-samples-build/
cd vision-samples-build

CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release \
-DAFFECTIVA_SDK_DIR=/path/to/auto-sdk \
-DBOOST_ROOT=/usr/ \
-DOpenCV_DIR=/path/to/opencv/build \
-DCMAKE_INSTALL_PREFIX=/path/to/install"

cmake $CMAKE_ARGS /path/to/cpp-sdk-samples/vision 
make -j4
make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$AFFECTIVA_SDK_DIR/lib
```

---

## Ubuntu 16

### Boost 
```
$ mkdir boost-build
$ cd boost-build
$ wget https://sourceforge.net/projects/boost/files/boost/1.63.0/boost_1_63_0.tar.gz
$ tar -xzvf boost_1_63_0.tar.gz
$ cd boost_1_63_0
$ ./bootstrap.sh
$ sudo ./b2 -j $(nproc) cxxflags=-fPIC threading=multi runtime-link=shared \
      --with-filesystem --with-program_options install
```

### Building with CMake

Specify the following CMake variables to identify the locations of various dependencies:

- **AFFECTIVA_SDK_DIR**: path to the folder where the Automotive SDK is installed
- **BOOST_ROOT** path to the Boost src tree


#### Linux (x86_64, aarch64)

For building under Linux, type the following command:

`$ cmake . -DCMAKE_BUILD_TYPE=[Release,Debug] <other args>`

Example script (replace directories starting with `/path/to` as appropriate):
```
# create a build directory
mkdir vision-samples-build/
cd vision-samples-build

CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release \
-DAFFECTIVA_SDK_DIR=/path/to/auto-sdk \
-DBOOST_ROOT=/path/to/boost-build \
-DOpenCV_DIR=/path/to/opencv \
-DCMAKE_INSTALL_PREFIX=/path/to/install"

cmake $CMAKE_ARGS /path/to/cpp-sdk-samples/vision 
make -j4
make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$AFFECTIVA_SDK_DIR/lib
```

The Affectiva SDK statically links a customized version of OpenCV, so if you run into double free or corruption errors, then you will need to preload the OpenCV library installed from package manager.

Use this command to find the path of libopencv_core.so.2.4

`ldconfig -p | grep libopencv_core.so.2.4`

Then set LD_PRELOAD to ensure it gets loaded first at runtime:
`export LD_PRELOAD=/path/to/libopencv_core.so.2.4`


##Docker Build Instructions

A Dockerfile is located in the top-level directory of this repo ([here](../Dockerfile)). To build the docker image, please refer to that file for instructions.

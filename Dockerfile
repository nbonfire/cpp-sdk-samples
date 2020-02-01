# A Docker file to be used for building the sample applications for the Linux SDK Ubuntu 16.04
#
# build:
# $ docker build --build-arg AFFECTIVA_AUTO_SDK_2_1_URL=$AFFECTIVA_AUTO_SDK_2_1_URL --build-arg BRANCH=$BRANCH --tag=affectiva-auto:v2.0-ics .
#
# the result will be an image that has the tar'ed artifact of the sample app and all of its dependencies installed
#
# run this container interactively:
# $ docker run -it --rm affectiva-auto:v2.1-ics
#
# running the webcam or mic demos interactively requires some privileges, devices, and access to the X11 socket:
# $ docker run -it --privileged --rm --net=host \
#        -v /tmp/.X11-unix:/tmp/.X11-unix  \
#        -v $XAUTHORITY:/root/.Xauthority \
#        -e DISPLAY=$DISPLAY     \
#        --device=/dev/video0 \
#        --device=/dev/snd \
#        affectiva-auto:v2.1-ics
#
# Then from the shell, run the following for the webcam demo:
# $ /opt/testapp-artifact/build/vision/bin/frame-detector-webcam-demo -d $AUTO_SDK_DIR/data
#



FROM ubuntu:16.04

RUN apt-get update &&\
    apt-get install -yqq software-properties-common\
                        git \
                        bc \
                        gfortran \
                        unzip \
                        wget \
                        g++ \
                        make \
                        libopencv-dev \
                        cmake \
                        libsndfile1-dev \
                        portaudio19-dev \
                        alsa-base \
                        alsa-utils > /dev/null

ENV SRC_DIR /opt/src
ENV BUILD_DIR /opt/build
ENV VISION_BUILD_DIR /opt/build/vision
ENV SPEECH_BUILD_DIR /opt/build/speech
ENV ARTIFACT_DIR /opt/testapp-artifact
ENV AUTO_SDK_DIR $SRC_DIR/affectiva-ics-sdk-2.1.0
ENV LD_LIBRARY_PATH $AUTO_SDK_DIR/lib
ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libopencv_core.so.2.4

#################################
###### Clone Sample App Repo ######
#################################

ARG BRANCH
RUN git clone -b $BRANCH https://github.com/Affectiva/cpp-sdk-samples.git $SRC_DIR/sdk-samples

#### BOOST ####
WORKDIR $SRC_DIR
RUN wget --quiet https://sourceforge.net/projects/boost/files/boost/1.63.0/boost_1_63_0.tar.gz --no-check-certificate && \
    tar -xf boost_1_63_0.tar.gz && \
    rm boost_1_63_0.tar.gz && \
    cd $SRC_DIR/boost_1_63_0 && \
    ./bootstrap.sh &&\
    ./b2 -j $(nproc) cxxflags=-fPIC threading=multi runtime-link=shared \
         --with-filesystem --with-program_options \
         install > /dev/null && \
    rm -rf $SRC_DIR/boost_1_63_0

#### DOWNLOAD AFFECTIVA AUTO SDK ####
WORKDIR $SRC_DIR
ARG AFFECTIVA_AUTO_SDK_2_1_URL
RUN mkdir -p $AUTO_SDK_DIR && cd $AUTO_SDK_DIR &&\
    wget --quiet $AFFECTIVA_AUTO_SDK_2_1_URL  &&\
    tar -xf affectiva-ics-sdk* && \
    rm -r $AUTO_SDK_DIR/affectiva-ics-sdk-ubuntu-xenial-xerus-*

#### BUILD SAMPLE APPS FOR VISION ####
RUN mkdir -p $VISION_BUILD_DIR &&\
    cd $VISION_BUILD_DIR &&\
    cmake -DOpenCV_DIR=/usr/ -DBOOST_ROOT=/usr/ -DAFFECTIVA_SDK_DIR=$AUTO_SDK_DIR $SRC_DIR/sdk-samples/vision &&\
    make -j$(nproc) > /dev/null

#### CREATE THE ARTIFACT ####
WORKDIR $ARTIFACT_DIR
RUN mkdir -p $ARTIFACT_DIR &&\
    cp -R $AUTO_SDK_DIR . &&\
    cp -R $BUILD_DIR . &&\
    tar -cf ../testapp-artifact.tar.gz .

WORKDIR $ARTIFACT_DIR

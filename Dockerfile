FROM ubuntu:16.04
MAINTAINER vicident

RUN apt-get update && apt-get install -y --no-install-recommends \
        automake \
        autoconf \
        git-core \
        yasm \
        build-essential \
        pkg-config \
        curl \
        git \
        software-properties-common \
        wget \
        gcc \
        g++ \
        cmake \
        telnet \
        python-dev \
        texinfo \
        libpng12-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff5-dev \
        libjasper-dev \
        libtbb-dev

RUN apt-get install -y unzip

# Install Anaconda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
     wget --no-check-certificate https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh -O ~/anaconda.sh && \
     /bin/bash ~/anaconda.sh -b -p /opt/conda && \
     rm ~/anaconda.sh
ENV PATH /opt/conda/bin:$PATH

# Install additional packages
RUN conda install -y scikit-image libgcc

# Install OpenCV
RUN mkdir /opt/opencv && mkdir /opt/opencv_contrib && cd /opt/opencv_contrib \
    && wget https://github.com/opencv/opencv_contrib/archive/3.2.0.zip \
    && unzip 3.2.0.zip \
    && cd /opt/opencv \
    && wget https://github.com/Itseez/opencv/archive/3.2.0.zip \
    && unzip 3.2.0.zip \
    && cd opencv-3.2.0 \
    && mkdir build \
    && cd /opt/opencv/opencv-3.2.0/build \
    && cmake -DWITH_CUDA=OFF \
    -DBUILD_TIFF=ON \
    -DBUILD_opencv_java=OFF \
    -DENABLE_AVX=ON \
    -DWITH_OPENGL=ON \
    -DWITH_OPENCL=ON \
    -DWITH_IPP=ON \
    -DWITH_TBB=ON \
    -DWITH_EIGEN=ON \
    -DWITH_V4L=ON \
    -DWITH_VTK=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUILD_opencv_python2=OFF \
    -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
    -DPYTHON3_EXECUTABLE=$(which python3) \
    -DPYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DPYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DINSTALL_PYTHON_EXAMPLES=ON \
    -DINSTALL_C_EXAMPLES=OFF \
    -DPYTHON_EXECUTABLE=/opt/conda/bin/python \
    -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/opencv_contrib-3.2.0/modules \
    -DBUILD_EXAMPLES=ON .. \
    && make -j 4 \
    && make install

RUN conda config --add channels conda-forge && conda install catboost tqdm

WORKDIR /root
VOLUME /root/ssd
COPY / /root
EXPOSE 8888
CMD jupyter notebook --ip=0.0.0.0


# This script installs Caffe and pycaffe on Ubuntu 14.04 x64 or 14.10 x64. CPU only, multi-threaded Caffe.
# Usage: 
# 0. Set up here how many cores you want to use during the installation:
# By default Caffe will use all these cores.
NUMBER_OF_CORES=2
# 1. Execute this script, e.g. "bash compile_caffe_ubuntu_14.04.sh" (~30 to 60 minutes on a new Ubuntu).
# 2. Open a new shell (or run "source ~/.bash_profile"). You're done. You can try 
#    running "import caffe" from the Python interpreter to test.

#http://caffe.berkeleyvision.org/install_apt.html : (general install info: http://caffe.berkeleyvision.org/installation.html)
cd
sudo apt-get update
#sudo apt-get upgrade -y # If you are OK getting prompted
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" # If you are OK with all defaults

#OpenCV
sudo apt-get install -y build-essential cmake git pkg-config
sudo apt-get install -y libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y git python2.7-dev gfortran
#OpenCv

#OpenBlas
cd ~
git clone https://github.com/xianyi/OpenBLAS
cd OpenBLAS
make FC=gfortran USE_OPENMP=1
sudo make PREFIX=/opt/OpenBLAS install
#sudo make PREFIX=/usr/local/ install
echo "export LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH " >> ~/.bashrc
source ~/.bash_profile
sudo ldconfig
#OpenBlas

#numpy
cd ~
git clone git://github.com/numpy/numpy.git numpy
cd numpy
cp site.cfg.example site.cfg
echo "
[openblas]
libraries = openblas
library_dirs = /opt/OpenBLAS/lib
include_dirs = /opt/OpenBLAS/include
runtime_library_dirs = /opt/OpenBLAS/lib" >> site.cfg
# ImportError: No module named setuptools
sudo apt-get install -y python-setuptools 
sudo apt-get install -y python-pip
sudo pip install cython
python setup.py build --fcompiler=gnu95
python setup.py install
#numpy

echo "export OMP_NUM_THREADS=$NUMBER_OF_CORES" >> ~/.bashrc 
source ~/.bashrc 
sudo ldconfig

#OpenCV 3.1
cd ~
git clone https://github.com/Itseez/opencv.git
cd opencv
git checkout 3.1.0

cd ~
git clone https://github.com/Itseez/opencv_contrib.git
cd opencv_contrib
git checkout 3.1.0

cd ~/opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
	-D BUILD_EXAMPLES=ON ..
make -j$NUMBER_OF_CORES
sudo make install

#OpenCV 3.1

sudo apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev
sudo apt-get install -y --no-install-recommends libboost-all-dev
sudo apt-get install -y libatlas-base-dev 
#sudo apt-get install -y python-dev 
#sudo apt-get install -y python-pip git

# For Ubuntu 14.04
sudo apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler 

# LMDB
# https://github.com/BVLC/caffe/issues/2729: Temporarily broken link to the LMDB repository #2729
#git clone https://gitorious.org/mdb/mdb.git
#cd mdb/libraries/liblmdb
#make && make install 

git clone https://github.com/LMDB/lmdb.git 
cd lmdb/libraries/liblmdb
sudo make -j$NUMBER_OF_CORES
sudo make install

# More pre-requisites 
sudo apt-get install -y cmake unzip doxygen
sudo apt-get install -y protobuf-compiler
sudo apt-get install -y libffi-dev python-dev build-essential
sudo pip install lmdb
sudo pip install numpy
sudo apt-get install -y python-numpy
sudo apt-get install -y gfortran # required by scipy
sudo pip install scipy # required by scikit-image
sudo apt-get install -y python-scipy # in case pip failed
sudo apt-get install -y python-nose
sudo pip install scikit-image # to fix https://github.com/BVLC/caffe/issues/50


# Get caffe (http://caffe.berkeleyvision.org/installation.html#compilation)
cd ~
git clone https://github.com/BVLC/caffe.git
cd caffe

# Prepare Python binding (pycaffe)
cd python
sed -i 's/numpy/#numpy/' requirements.txt #already install numpy
for req in $(cat requirements.txt); do sudo pip install $req; done
echo "export PYTHONPATH=$(pwd):$PYTHONPATH " >> ~/.bashrc # to be able to call "import caffe" from Python after reboot
source ~/.bashrc # Update shell 
cd ..

# Compile caffe and pycaffe
cp Makefile.config.example Makefile.config
sed -i 's/# CPU_ONLY := 1/CPU_ONLY := 1/' Makefile.config
sed -i 's/# OPENCV_VERSION := 3/OPENCV_VERSION := 3/' Makefile.config
sed -i 's/BLAS := atlas/BLAS := open/' Makefile.config
sed -i 's/# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/' Makefile.config
echo "
BLAS_LIB := /opt/OpenBLAS/lib
BLAS_INCLUDE := /opt/OpenBLAS/include" >> Makefile.config


mkdir build
cd build
cmake ..
cd ..
make pycaffe -j$NUMBER_OF_CORES
make all -j$NUMBER_OF_CORES
make test -j$NUMBER_OF_CORES
make runtest -j$NUMBER_OF_CORES
make distribute
#make matcaffe


# Bonus for other work with pycaffe
sudo pip install pydot
sudo apt-get install -y graphviz
sudo pip install scikit-learn

source ~/.bash_profile 
sudo ldconfig

# Caffe Web_demo
sudo pip install -r examples/web_demo/requirements.txt
# Reference CaffeNet Model and the ImageNet Auxiliary Data
./scripts/download_model_binary.py models/bvlc_reference_caffenet
./data/ilsvrc12/get_ilsvrc_aux.sh
#Reference CaffeNet Model and the ImageNet Auxiliary Data


# NGINX
sudo apt-get install -y nginx
sudo /etc/init.d/nginx start
sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-available/web_demo
sudo ln -s /etc/nginx/sites-available/web_demo /etc/nginx/sites-enabled/web_demo
echo ' 
server {
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /static {
        alias  /home/www/flask_project/static/;
    }
}' | sudo tee -a /etc/nginx/sites-available/web_demo
sudo /etc/init.d/nginx restart
python examples/web_demo/app.py

# Caffe Web_demo and NGINX


# At the end, you need to run "source ~/.bash_profile" manually or start a new shell to be able to do 'python import caffe', 
# because one cannot source in a bash script. (http://stackoverflow.com/questions/16011245/source-files-in-a-bash-script)

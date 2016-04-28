cd ~
sudo apt-get update
sudo apt-get upgrade -y # If you are OK getting prompted
#sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" # If you are OK with all defaults

#OpenCV
sudo apt-get install -y build-essential cmake git pkg-config
sudo apt-get install -y libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y git python2.7-dev gfortran
#OpenCv

sudo apt-get install libopenblas-dev git
#numpy

sudo apt-get install -y python-setuptools 
sudo apt-get install -y python-pip git
sudo pip install numpy
sudo pip install cython

#numpy



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
make
sudo make install

#OpenCV 3.1

sudo apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev
sudo apt-get install -y --no-install-recommends libboost-all-dev
sudo apt-get install -y libatlas-base-dev 

# For Ubuntu 14.04
sudo apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler 

# LMDB
# https://github.com/BVLC/caffe/issues/2729: Temporarily broken link to the LMDB repository #2729
#git clone https://gitorious.org/mdb/mdb.git
#cd mdb/libraries/liblmdb
#make && make install 

git clone https://github.com/LMDB/lmdb.git 
cd lmdb/libraries/liblmdb
sudo make
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
#sed -i 's/numpy/#numpy/' requirements.txt #already install numpy
for req in $(cat requirements.txt); do sudo pip install $req; done
echo "export PYTHONPATH=$(pwd):$PYTHONPATH " >> ~/.bash_profile # to be able to call "import caffe" from Python after reboot
source ~/.bash_profile # Update shell 
cd ..

# Compile caffe and pycaffe
cp Makefile.config.example Makefile.config
sed -i 's/# CPU_ONLY := 1/CPU_ONLY := 1/' Makefile.config
sed -i 's/# OPENCV_VERSION := 3/OPENCV_VERSION := 3/' Makefile.config
sed -i 's/BLAS := atlas/BLAS := open/' Makefile.config
sed -i 's/# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/' Makefile.config
mkdir build
cd build
cmake ..
cd ..
make pycaffe
make all
make test
make runtest
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


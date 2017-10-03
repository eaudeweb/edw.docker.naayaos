FROM centos:7

ENV GOOGLE_AUTH_CLIENT_ID ''
ENV GOOGLE_AUTH_CLIENT_SECRET ''
ENV reCAPTCHA_PUBLIC_KEY ''
ENV reCAPTCHA_PRIVATE_KEY ''
ENV WEBEX_CONTACTS ''

# Enable epel release and install libraries and packages
RUN yum -y updateinfo && yum -y install wget \
 && wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm \
 && rpm -ivh epel-release-7-10.noarch.rpm \
 && yum-config-manager --add-repo http://www.nasm.us/nasm.repo \
 && yum -y install \
    cryptopp-devel \
    curl-devel \
    cyrus-sasl-devel \
    freetype-devel \
    glibc-devel \
    glib2-devel \
    gvfs-devel \
#   icu for wkhtmltopdf
    icu \
    libjpeg-turbo-devel \
    libxml2-devel \
    libxslt-devel \
    libyaml-devel \
    mariadb-devel mysql-libs \
    openldap-devel \
    openssl-devel \
    python-devel \
    readline-devel \
    sqlite-devel \
    zlib-devel \
    autoconf \
    automake \
    cmake cronie \
    freetype-devel \
    gcc \
    gcc-c++ \
    git \
    libtool \
    make \
    nasm \
#   openssl for wkhtmltopdf
    openssl \
    patch \
    pkgconfig \
    python-virtualenv \
    subversion \
    tar \
    vim \
    which \
#   fonts for wkhtmltopdf
    xorg-x11-fonts-75dpi \
    xorg-x11-fonts-Type1 \
    yasm \
 && yum clean all \
# Install libx264, libfdk_aac, lame, ffmpeg
 && git clone --depth 1 git://git.videolan.org/x264 \
 && cd x264 && ./configure --enable-static && make && make install && ldconfig \
 && cd .. && rm -r x264 \
 && git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac \
 && cd fdk-aac && autoreconf -fiv && ./configure --disable-shared && make && make install \
 && cd .. && rm -r fdk-aac \
 && wget -O lame-3.99.5.tar.gz http://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz/download \
 && tar xvfz lame-3.99.5.tar.gz \
 && cd lame-3.99.5 && ./configure && make && make install && ldconfig \
 && cd .. && rm -r lame-3.99.5 lame-3.99.5.tar.gz \
 && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
 && /usr/bin/pkg-config --libs x264 \
 && git clone --depth 1 git://source.ffmpeg.org/ffmpeg \
 && cd ffmpeg \
 && PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure --enable-gpl \
        --enable-nonfree --enable-libfdk-aac --enable-libfreetype \
        --enable-libmp3lame --enable-libx264 \
 && make && make install \
 && cd .. \
 && rm -r ffmpeg \
#library path update and install setuptools, pip
 && ldconfig /usr/local/lib \
 && wget https://pypi.python.org/packages/source/s/setuptools/setuptools-0.6c11.tar.gz \
 && tar xvfz setuptools-0.6c11.tar.gz && cd setuptools-0.6c11 \
 && python2.7 setup.py install \
 && cd .. \
 && rm -r setuptools-0.6c11 setuptools-0.6c11.tar.gz \
 && easy_install pip \
#install wkhtmltopdf
 && wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm \
 && rpm -Uvh wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm \
 && rm wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm \
#final setup
 && groupadd -g 500 zope \
 && useradd  -g 500 -u 500 -m -s /bin/bash zope \
 && echo 'export PATH=$PATH:/usr/local/bin' >> /home/zope/.bashrc \
 && echo 'export TERM=xterm' >> /home/zope/.bashrc

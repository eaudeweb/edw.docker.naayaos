FROM centos:7

ENV GOOGLE_AUTH_CLIENT_ID ''
ENV GOOGLE_AUTH_CLIENT_SECRET ''
ENV reCAPTCHA_PUBLIC_KEY ''
ENV reCAPTCHA_PRIVATE_KEY ''
ENV WEBEX_CONTACTS ''

# Enable epel release and install libraries and packages
RUN yum -y updateinfo && yum -y install wget \
 && wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm \
 && rpm -ivh epel-release-7-11.noarch.rpm \
 && rm -rf epel-release-7-11.noarch.rpm \
 && yum-config-manager --add-repo http://www.nasm.us/nasm.repo \
 && yum -y install \
    cronie \
    cryptopp-devel \
    curl-devel \
    cyrus-sasl-devel \
    glibc-devel \
    glib2-devel \
    gvfs-devel \
    libxml2-devel \
    libxslt-devel \
    libyaml-devel \
    mariadb-devel mysql-libs \
    openldap-devel \
    patch \
    python-devel \
    python-virtualenv \
    readline-devel \
    sqlite-devel \
    subversion \
    tar \
    vim \
    which \
    yasm \
#   libpng, libjpeg, openssl, icu, libx11, libXext, libXrender
#   xorg-x11-fonts-Type1 and xorg-x11-fonts-75dpi are needed for wkhtmltopdf
    libpng \
    libjpeg-turbo-devel \
    openssl-devel \
    icu \
    libx11 \
    libXext \
    libXrender \
    xorg-x11-fonts-Type1 \
    xorg-x11-fonts-75dpi \
#   ffmpeg dependencies: autoconf, automake, bzip2, cmake, freetype-devel, gcc,
#   gcc-c++, libtool, make, nasm, pkgconfig, zlib-devel, git
    autoconf \
    automake \
    cmake \
    freetype-devel \
    gcc \
    gcc-c++ \
    git \
    libtool \
    make \
    nasm \
    pkgconfig \
    zlib-devel \
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

 && curl -O https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.2.tar.gz \
 && tar xzvf libogg-1.3.2.tar.gz \
 && cd libogg-1.3.2 && ./configure --disable-shared && make && make install \
 && cd .. && rm -r libogg-1.3.2 libogg-1.3.2.tar.gz \

 && curl -O https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.5.tar.gz \
 && tar xzvf libvorbis-1.3.5.tar.gz && cd libvorbis-1.3.5 \
 && LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include" ./configure --prefix="/usr/local" --with-ogg="/usr/local" --disable-shared \
 && make && make install && cd .. && rm -r libvorbis-1.3.5 libvorbis-1.3.5.tar.gz \

 && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
 && /usr/bin/pkg-config --libs vorbis x264 \
 && git clone --depth 1 git://source.ffmpeg.org/ffmpeg \
 && cd ffmpeg \
 && PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure \
        --extra-cflags="-I/usr/local/include" --extra-ldflags="-L/usr/local/lib -ldl" \
        --pkg-config-flags="--static" \
        --enable-gpl \
        --enable-nonfree \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libvorbis \
        --enable-libx264 \
 && make && make install \
 && cd .. \
 && rm -r ffmpeg \

#install wkhtmltopdf
 && wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
 && unxz wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
 && tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar \
 && mv wkhtmltox/bin/* /usr/local/bin/ \
 && rm -rf wkhtmltox \
 && rm -f wkhtmltox-0.12.4_linux-generic-amd64.tar \

#final setup
 && groupadd -g 500 zope \
 && useradd  -g 500 -u 500 -m -s /bin/bash zope \
 && echo 'export PATH=$PATH:/usr/local/bin' >> /home/zope/.bashrc \
 && echo 'export TERM=xterm' >> /home/zope/.bashrc

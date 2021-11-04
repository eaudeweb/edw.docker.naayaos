FROM centos:7.9.2009

ENV GOOGLE_AUTH_CLIENT_ID ''
ENV GOOGLE_AUTH_CLIENT_SECRET ''
ENV reCAPTCHA_PUBLIC_KEY ''
ENV reCAPTCHA_PRIVATE_KEY ''
ENV WEBEX_CONTACTS ''
ENV LD_LIBRARY_PATH '/usr/local/lib'

# Enable epel release and install libraries and packages
RUN yum -y updateinfo && yum -y install wget \
 && wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm \
 && rpm -ivh epel-release-7-14.noarch.rpm \
 && rm -rf epel-release-7-14.noarch.rpm \
 && yum --enablerepo=extras install epel-release \
 && yum -y install \
    bzip2 \
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
    libX11 \
    libXext \
    libXrender \
    xorg-x11-fonts-Type1 \
    xorg-x11-fonts-75dpi \
#   ffmpeg dependencies: autoconf, automake, bzip2, cmake, freetype-devel, gcc,
#   gcc-c++, libtool, make, nasm (will be built), pkgconfig, zlib-devel, git
    autoconf \
    automake \
    cmake \
#    freetype-devel ffmpeg build doesn't find it, comment for now, not needed
    gcc \
    gcc-c++ \
    git \
    libtool \
    make \
    pkgconfig \
    zlib-devel \
 && yum clean all \
# Install libx264, libfdk_aac, lame, ffmpeg

 && curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 \
 && tar xjvf nasm-2.15.05.tar.bz2 \
 && cd nasm-2.15.05 \
 && ./autogen.sh \
 && ./configure \
 && make && make install \
 && cd .. && rm -rf nasm-2.15.05.tar.bz2 nasm-2.15.05 \

 && git clone --branch stable --depth 1 https://code.videolan.org/videolan/x264.git \
 && cd x264 \
 && PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure --prefix="/usr/local/" --enable-static \
 && make && make install \
 && cd .. && rm -rf x264 \

 && git clone --branch stable --depth 2 https://bitbucket.org/multicoreware/x265_git \
 && cd x265_git/build/linux \
 && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/local/" -DENABLE_SHARED:bool=off ../../source \
 && make && make install \
 && cd ../../../ && rm -rf x265_git \

 && git clone --depth 1 https://github.com/mstorsjo/fdk-aac \
 && cd fdk-aac \
 && autoreconf -fiv \
 && ./configure --prefix="/usr/local" --disable-shared \
 && make && make install \
 && cd .. && rm -rf fdk-aac \

 && wget -O lame-3.100.tar.gz http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz \
 && tar xvfz lame-3.100.tar.gz \
 && cd lame-3.100 && ./configure --prefix="/usr/local/" --bindir="/usr/local/bin" --enable-nasm \
 && make && make install \
 && cd .. && rm -rf lame-3.100 lame-3.100.tar.gz \

 && curl -O https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.5.tar.gz \
 && tar xzvf libogg-1.3.5.tar.gz \
 && cd libogg-1.3.5 && ./configure --prefix="/usr/local/" --disable-shared \
 && make && make install \
 && cd .. && rm -rf libogg-1.3.5 libogg-1.3.5.tar.gz \

 && curl -O https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.7.tar.gz \
 && tar xzvf libvorbis-1.3.7.tar.gz && cd libvorbis-1.3.7 \
 && LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include" ./configure --prefix="/usr/local/" --with-ogg="/usr/local/" --disable-shared \
 && make && make install && cd .. && rm -rf libvorbis-1.3.7 libvorbis-1.3.7.tar.gz \

 && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
 && /usr/bin/pkg-config --libs vorbis x264 \
 && git clone --depth 1 git://source.ffmpeg.org/ffmpeg \
 && cd ffmpeg \
 && PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure \
        --prefix="/usr/local/" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/usr/local/include" \
        --extra-ldflags="-L/usr/local/lib" \
        --extra-libs=-lpthread \
        --bindir="/usr/local/bin" \
        --enable-gpl \
        --enable-nonfree \
        --enable-libfdk-aac \
#        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libvorbis \
        --enable-libx264 \
        --enable-libx265 \
 && make && make install \
 && cd .. \
 && rm -rf ffmpeg \

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
 && echo 'export TERM=xterm' >> /home/zope/.bashrc

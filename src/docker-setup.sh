#!/bin/bash
set -e

buildDeps=$(cat "/build-deps.txt")

runDeps=$(cat "/run-deps.txt")

echo "========================================================================="
echo "Installing $buildDeps"
echo "========================================================================="

apt-get update
apt-get install -y --no-install-recommends $buildDeps

echo "========================================================================="
echo "Installing $runDeps"
echo "========================================================================="

apt-get install -y --no-install-recommends $runDeps

echo "========================================================================="
echo "Installing ffmpeg deps and ffmpeg"
echo "========================================================================="

git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --disable-shared
make
make install
cd ..
rm -rf fdk-aac

git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure \
      --enable-gpl \
      --enable-gnutls \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-nonfree
#      --enable-libfreetype \
make -j5
make install
make distclean
hash -r
cd ..
rm -rf ffmpeg

echo "========================================================================="
echo "Installing wkhtmltopdf"
echo "========================================================================="

wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
unxz wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar
mv wkhtmltox/bin/* /usr/local/bin/
rm -rf wkhtmltox wkhtmltox-0.12.4_linux-generic-amd64.tar

echo "========================================================================="
echo "Unininstalling $buildDeps"
echo "========================================================================="

apt-get purge -y --auto-remove $buildDeps

echo "========================================================================="
echo "Reinstall $runDeps, since some were uninstalled in previous step"
echo "========================================================================="

apt-get install -y --no-install-recommends $runDeps

echo "========================================================================="
echo "enable ProxyPass and Headers in apache"
echo "========================================================================="

a2enmod proxy_http
a2enmod headers

echo "========================================================================="
echo "Cleaning up cache..."
echo "========================================================================="

rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

echo "========================================================================="
echo "Add zope user"
echo "========================================================================="

groupadd -g 500 zope
useradd  -g 500 -u 500 -m -s /bin/bash zope
echo 'export TERM=xterm' >> /home/zope/.bashrc

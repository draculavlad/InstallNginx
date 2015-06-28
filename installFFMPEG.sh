#!/bin/bash
# references: http://wiki.razuna.com/display/ecp/FFMpeg+Installation+on+CentOS+and+RedHat

# install dependency
# if for centos 6 then do [rpm -Uhv http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm]
rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
yum -y update
yum install -y cmake git mercurial  
yum install -y glibc gcc gcc-c++ autoconf automake libtool git make nasm pkgconfig
yum install -y SDL-devel a52dec a52dec-devel alsa-lib-devel faac faac-devel faad2 faad2-devel
yum install -y freetype-devel giflib gsm gsm-devel imlib2 imlib2-devel lame lame-devel libICE-devel libSM-devel libX11-devel
yum install -y libXau-devel libXdmcp-devel libXext-devel libXrandr-devel libXrender-devel libXt-devel
yum install -y libogg libvorbis vorbis-tools mesa-libGL-devel mesa-libGLU-devel xorg-x11-proto-devel zlib-devel
yum install -y libtheora theora-tools
yum install -y ncurses-devel
yum install -y libdc1394 libdc1394-devel
yum install -y amrnb-devel amrwb-devel opencore-amr-devel

# Install xvid
cd /opt
wget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
tar xzvf xvidcore-1.3.2.tar.gz
cd xvidcore/build/generic
./configure --prefix="$HOME/ffmpeg_build"
make
make install

# Install LibOgg
cd /opt
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
tar xzvf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

# Install Libvorbis
cd /opt
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install

# Install Libtheora
cd /opt
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
tar xzvf libtheora-1.1.1.tar.gz
cd libtheora-1.1.1
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest
make
make install

# Install Aacenc
cd /opt
wget http://downloads.sourceforge.net/opencore-amr/vo-aacenc-0.1.2.tar.gz
tar xzvf vo-aacenc-0.1.2.tar.gz
cd vo-aacenc-0.1.2
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

# Install Yasm
yum remove yasm
cd /opt
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzfv yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
export "PATH=$PATH:$HOME/bin" 

# Install Libvpx
cd /opt
#git clone http://git.chromium.org/webm/libvpx.git
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx
#git checkout tags/v.1.3.0
git checkout v1.3.0
./configure --prefix="$HOME/ffmpeg_build" --disable-examples
make
make install

# Install X264
cd /opt
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static 
make
make install

# Install faac
cd /opt
wget http://downloads.sourceforge.net/faac/faac-1.28.tar.gz
tar -xzf faac-1.28.tar.gz
cd faac-1.28
./bootstrap
./configure
make && make install
ldconfig
cd

# Configure Libraries
export LD_LIBRARY_PATH=/usr/local/lib/
echo /usr/local/lib >> /etc/ld.so.conf.d/custom-libs.conf
ldconfig


# Compile FFmpeg (the configure options have to be on one line)
cd /opt
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
git checkout release/2.5
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH
./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" \
--extra-libs=-ldl --enable-version3 --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvpx --enable-libfaac \
--enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libvo-aacenc --enable-libxvid --disable-ffplay \
--enable-gpl --enable-postproc --enable-nonfree --enable-avfilter --enable-pthreads
make
make install

# test ffmpeg
# ffmpeg
# ffmpeg version 2.2 Copyright (c) 2000-2014 the FFmpeg developers
#  built on Mar 28 2014 01:28:21 with gcc 4.4.7 (GCC) 20120313 (Red Hat 4.4.7-4)
#  configuration: --enable-version3 --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvpx --enable-libfaac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libvo-aacenc --enable-libxvid --disable-ffplay --enable-shared --enable-gpl --enable-postproc --enable-nonfree --enable-avfilter --enable-pthreads --extra-cflags=-fPIC
#  libavutil      52. 66.100 / 52. 66.100
#  libavcodec     55. 52.102 / 55. 52.102
#  libavformat    55. 33.100 / 55. 33.100
#  libavdevice    55. 10.100 / 55. 10.100
#  libavfilter     4.  2.100 /  4.  2.100
#  libswscale      2.  5.102 /  2.  5.102
#  libswresample   0. 18.100 /  0. 18.100
#  libpostproc    52.  3.100 / 52.  3.100
# Hyper fast Audio and Video encoder
# usage: ffmpeg [options] [[infile options] -i infile]... {[outfile options] outfile}...
# 
# test convert
# ffmpeg -i movie.mov -vcodec libx264 -vpre hq -acodec libfaac movie.mp4

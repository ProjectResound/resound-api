FROM ruby:2.3
MAINTAINER Louise Yang (louise.yang@scpr.org)

# FFMPEG Installation START ================

# Add multimedia sources so we can install FFMPEG
RUN echo "deb http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list
RUN apt-get update && apt-get -y --force-yes install deb-multimedia-keyring

# Can get rid of openjpeg??
# All the required libraries needed to support FFMPEG
RUN apt-get install -y --force-yes \
    build-essential \
    libvorbis-dev \
    libfdk-aac-dev \
    yasm \
    pkg-config \
    libfaac-dev \
    libx264-dev

# Build and install FFMPEG
RUN mkdir ffmpeg_extracted && \
    cd ffmpeg_extracted && \
    wget http://ffmpeg.org/releases/ffmpeg-3.2.2.tar.bz2 && \
    cd .. && \
    mkdir ffmpeg_src && \
    cd ffmpeg_src && \
    tar xvjf ../ffmpeg_extracted/ffmpeg-3.2.2.tar.bz2 && \
    cd ffmpeg-3.2.2 && \
    ./configure \
    --enable-gpl \
    --enable-postproc \
    --enable-swscale \
    --enable-avfilter \
    --enable-libvorbis \
    --enable-libx264 \
    --enable-shared \
    --enable-pthreads \
    --enable-libfdk-aac \
    --enable-nonfree && \
    make && \
    make install && \
    echo "include /usr/local/lib/" >> /etc/ld.so.conf && \
    ldconfig && \
    FFMPEG_PATH="$(which ffmpeg)" && \
    cd .. && \
    rm -rf ffmpeg_extracted && \
    rm -rf ffmpeg_src

# FFMPEG Installation END =================

# RAILS Installation START ================

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

RUN apt-get install -y \
    nodejs \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    mysql-client \
    postgresql-client \
    sqlite3 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

# RAILS Installation END ===================

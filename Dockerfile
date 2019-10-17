FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
  ruby-dev \
  gcc \
  make \
  cmake \
  curl \
  ruby \
  rubygems \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN gem install fpm -v 1.9.3 --no-ri --no-rdoc

RUN make shared && cd build && make && cd ../
COPY build/libMultiMarkdown.so ./

RUN fpm \
  -s dir \
  -t deb \
  -n multimarkdown \
  -v 6.4.0 \
  --after-install ldconfig.sh \
  -p multimarkdown_VERSION_ARCH.deb \
  Sources/libMultiMarkdown/include/=/usr/include/ \
  libMultiMarkdown.so=/usr/lib/

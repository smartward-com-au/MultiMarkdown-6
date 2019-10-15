FROM ubuntu:16.04
LABEL maintainer="catherine.wise@smartward.com.au"

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

VOLUME [ "/tmp/fpm" ]
WORKDIR /tmp/fpm

RUN make shared && cd build && make && cd ../
COPY build/libMultiMarkdown.so ./

RUN fpm \
  -s dir \
  -t deb \
  -n multimarkdown \
  -v 6.4.0 \
  -p multimarkdown_VERSION_ARCH.deb \
  Sources/libMultiMarkdown/include=/usr/include/ \
  libMultiMarkdown.so=/usr/lib/

#   -d "libstdc++6 >= 4.4.3" \

ENTRYPOINT [ "/usr/local/bin/fpm" ]
CMD [ "--help" ]

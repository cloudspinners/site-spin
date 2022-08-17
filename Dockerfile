FROM ruby:3.1.2-alpine3.16

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk add --update --no-cache \
bash \
  binutils \
  build-base \
  curl \
  curl-dev \
  git \
  gnupg \
  make \
  openssh-client \
  py3-pip \
  python3-dev \
  shadow \
  sudo \
  tree \
  wget

RUN ln -sf python3 /usr/bin/python

# dojo helper script
ENV DOJO_VERSION=0.11.0
RUN git clone --depth 1 -b ${DOJO_VERSION} \
  https://github.com/kudulab/dojo.git /tmp/dojo_git && \
  /tmp/dojo_git/image_scripts/src/install.sh && \
  rm -r /tmp/dojo_git

# dojo user
COPY image/bashrc /home/dojo/.bashrc
COPY image/profile /home/dojo/.profile
RUN chown dojo:dojo /home/dojo/.bashrc /home/dojo/.profile


# install assume-role which is a handy tool
RUN wget --tries=3 --retry-connrefused --wait=3 --random-wait \
    --quiet \
    https://github.com/remind101/assume-role/releases/download/0.3.2/assume-role-Linux && \
  chmod +x ./assume-role-Linux && \
  mv ./assume-role-Linux /usr/bin/assume-role

COPY image/etc_dojo.d/scripts/* /etc/dojo.d/scripts/
COPY image/inputrc /etc/inputrc


# awscli
RUN apk add gcompat
ENV AWS_CLI_VERSION=2.1.39
ENV CPU_ARCH=x86_64
COPY image/aws.gpg /opt/aws.gpg
# TODO: Figure out how to support x86_64 and aarch64 with multi-cpu architecture support
RUN curl -sL \
    https://awscli.amazonaws.com/awscli-exe-linux-${CPU_ARCH}-${AWS_CLI_VERSION}.zip.sig \
    -o awscliv2.sig && \
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${CPU_ARCH}-${AWS_CLI_VERSION}.zip" \
    -o "awscliv2.zip" && \
  gpg --import /opt/aws.gpg && \
  gpg --verify awscliv2.sig awscliv2.zip && \
  unzip awscliv2.zip
RUN pwd && ls -alF ./aws
RUN tree
RUN  ./aws/install && \
  rm -rf awscliv2.zip
RUN uname -a
RUN aws --version

# jekyll
ENV GEM_HOME=/home/dojo/.bundle
ENV BUNDLE_PATH=/home/dojo/.bundle
ENV BUNDLE_BIN=/home/dojo/bin
ENV PATH=/home/dojo/bin:$PATH

RUN mkdir -p /home/dojo/.bundle /home/dojo/bin
RUN chown -R dojo:dojo /home/dojo/.bundle /home/dojo/bin

COPY image/Gemfile /home/dojo/Gemfile
COPY image/Gemfile.lock /home/dojo/Gemfile.lock
RUN gem install bundler
RUN cd /home/dojo && bundle install

# BATS testing tool
ENV BATS_CORE_VERSION=1.7.0
ENV BATS_HELPER_DIR=/opt

RUN cd /tmp && \
  git clone --depth 1 -b v${BATS_CORE_VERSION} https://github.com/bats-core/bats-core.git && \
  cd bats-core && \
  ./install.sh ${BATS_HELPER_DIR} && \
  rm -r /tmp/bats-core && \
  ln -s /opt/bin/bats /usr/bin/bats

ENV BATS_SUPPORT_VERSION=0.3.0
RUN git clone -b v${BATS_SUPPORT_VERSION} https://github.com/bats-core/bats-support.git ${BATS_HELPER_DIR}/bats-support

ENV BATS_ASSERT_VERSION=2.0.0
RUN git clone -b v${BATS_ASSERT_VERSION} https://github.com/bats-core/bats-assert.git ${BATS_HELPER_DIR}/bats-assert

# Copy self-tests into the image
COPY test/self/  /opt/site-spin/test/
RUN chown -R dojo:dojo /opt/site-spin/test

# Set version environment variables
ARG EXTERNAL_VERSION_NUMBER not_set
ENV SITE_SPIN_VERSION=$EXTERNAL_VERSION_NUMBER
RUN echo "EXTERNAL_VERSION_NUMBER = $EXTERNAL_VERSION_NUMBER"
RUN echo "SITE_SPIN_VERSION = $SITE_SPIN_VERSION"

EXPOSE 4000

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]

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
  tree \
  wget

# dojo helper script
ENV DOJO_VERSION=0.11.0
RUN git clone --depth 1 -b ${DOJO_VERSION} \
  https://github.com/kudulab/dojo.git /tmp/dojo_git && \
  /tmp/dojo_git/image_scripts/src/install.sh && \
  rm -r /tmp/dojo_git

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
  unzip -q awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip
RUN uname -a
RUN aws --version


# dojo user
COPY image/bashrc /home/dojo/.bashrc
COPY image/profile /home/dojo/.profile
RUN chown dojo:dojo /home/dojo/.bashrc /home/dojo/.profile

# TODO: Use either curl or wget everywhere consistently, rather than both

# install assume-role which is a handy tool
RUN wget --tries=3 --retry-connrefused --wait=3 --random-wait \
    --quiet \
    https://github.com/remind101/assume-role/releases/download/0.3.2/assume-role-Linux && \
  chmod +x ./assume-role-Linux && \
  mv ./assume-role-Linux /usr/bin/assume-role

COPY image/etc_dojo.d/scripts/* /etc/dojo.d/scripts/
COPY image/inputrc /etc/inputrc

# jekyll
ENV BUNDLE_PATH=/home/dojo/.bundle
RUN gem install bundler
RUN bundle install
RUN choown -R dojo:dojo /home/dojo/.bundle


ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]

FROM php:7.4

# Set correct environment variables
ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer
ENV PATH=$HOME/.yarn/bin:$PATH
ENV GOSS_VERSION="0.4.4"
ENV PHP_VERSION=7.4
ENV NODE_VERSION=16

USER root
WORKDIR /tmp

# COPY INSTALL SCRIPTS
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN apt-get update
RUN apt-get -y install apt-transport-https ca-certificates 
RUN apt upgrade -yq
RUN apt install -yq \
      build-essential \
      curl \
      git \
      gnupg2 \
      jq \
      libc-client-dev \
      openssh-client \
      python \
      python-dev \
      rsync \
      sudo \
      unzip \
      zip \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get install nodejs -yq \
    && npm i -g --force npm \
    && curl -o- -L https://yarnpkg.com/install.sh | bash \
    && npm cache clean --force

RUN chmod a+x $HOME/.yarn/bin/yarn

COPY ./scripts/*.sh /tmp/
RUN chmod +x /tmp/*.sh

# Install
# RUN bash ./packages.sh
# RUN bash ./node.sh
RUN bash ./extensions.sh

RUN adduser --disabled-password --gecos "" $IMAGE_USER && \
  echo "PATH=$(yarn global bin):$PATH" >> /root/.profile && \
  echo "PATH=$(yarn global bin):$PATH" >> /root/.bashrc && \
  echo "$IMAGE_USER  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers && \
  mkdir -p /var/www/html \
  && rm -rf ~/.composer/cache/* \
  && chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME \
  && curl -fsSL https://goss.rocks/install | GOSS_VER=v${GOSS_VERSION} sh

USER $IMAGE_USER

WORKDIR /var/www/html

FROM php:7.4

# Set correct environment variables
ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer
ENV PATH=$HOME/.yarn/bin:$PATH
ENV GOSS_VERSION="0.4.4"
ENV PHP_VERSION=7.4
ENV NODE_VERSION=18

USER root
WORKDIR /tmp

# COPY INSTALL SCRIPTS
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY ./scripts/*.sh /tmp/
RUN chmod +x /tmp/*.sh

# Install2
RUN bash ./packages.sh
RUN bash ./node.sh
RUN bash ./extensions.sh

RUN adduser --disabled-password --gecos "" $IMAGE_USER && \
  echo "PATH=$(yarn global bin):$PATH" >> /root/.profile && \
  echo "PATH=$(yarn global bin):$PATH" >> /root/.bashrc && \
  echo "$IMAGE_USER  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers && \
  mkdir -p /var/www/html \
#   && composer global require "hirak/prestissimo:^0.3"  \
  && rm -rf ~/.composer/cache/* \
  && chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME \
  && curl -fsSL https://goss.rocks/install | GOSS_VER=v${GOSS_VERSION} sh \
  && bash ./cleanup.sh

USER $IMAGE_USER

WORKDIR /var/www/html

#!/usr/bin/env bash

set -euo pipefail

LOCAL_NODE_VERSION=${NODE_VERSION:-18}

# NODE JS
curl -sL "https://deb.nodesource.com/setup_${LOCAL_NODE_VERSION}.x" | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get install nodejs -yq \
    && npm i -g --force npm \
    && curl -o- -L https://yarnpkg.com/install.sh | bash \
    && npm cache clean --force

xargs sudo chmod a+x $HOME/.yarn/bin/yarn

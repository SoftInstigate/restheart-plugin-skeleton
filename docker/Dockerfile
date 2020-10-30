FROM softinstigate/restheart

LABEL maintainer="SoftInstigate <info@softinstigate.com>"

ENV NODE_VERSION=12.6.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

WORKDIR /opt/
COPY package.json package-lock.json ./watcher/
COPY restheart.sh ./

WORKDIR /opt/watcher
RUN npm install

WORKDIR /opt/
ENTRYPOINT [ "/opt/restheart.sh" ]
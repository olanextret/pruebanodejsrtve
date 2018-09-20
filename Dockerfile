# https://hub.docker.com/_/debian/
FROM centos:7

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN yum update -y \
#    && yum install -y curl \
    && yum install -y java-1.8.0-openjdk \
    && yum install -y swig

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.7.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install 6.7.0 \
    && nvm use default

#Add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATHUN
RUN /bin/cp /bin/* /usr/local/nvm/versions/node/v6.7.0/bin/

# confirm installation
RUN node -v
RUN npm -v

#Carpetas
RUN mkdir -p /conf/aplicaciones
RUN mkdir /conf/pm2
RUN mkdir -p /logs/aplicaciones/

RUN npm install pm2 -g
RUN npm install express
CMD pm2 list

#COPY app.js /conf/aplicaciones/app.js
RUN echo "var express = require('express'); \
var app = express(); \
app.get('/', function (req, res) { \
  for(var i=0; i < 1000000000; i++); \
  res.send('Hello World!'); \
}); \
app.listen(3000, function () { \
  console.log('Example app listening on port 3000!'); \
});" > /conf/aplicaciones/app.js

CMD [ "pm2-runtime", "start", "/conf/aplicaciones/app.js", " --output /logs/aplicaciones/out.log", " --error /logs/aplicaciones/error.log"]

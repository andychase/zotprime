FROM  ubuntu:latest as intermediate
ARG ZOTPRIME_VERSION=2

RUN set -eux; \ 
    apt update && \
    apt install -y zstd xvfb dbus-x11 libgtk-3-0 \
    libx11-xcb1 libdbus-glib-1-2 libxt6 \
    nodejs npm \
    curl 7zip git bash python3 zip perl rsync xxd
WORKDIR /usr/src/app
COPY . .


WORKDIR /usr/src/app/client/zotero-client

ARG HOST_DS=http://localhost:8080/
ARG HOST_ST=ws://localhost:8081/
RUN set -eux; \
        sed -i "s#https://api.zotero.org/#$HOST_DS#g" resource/config.js; \
        sed -i "s#wss://stream.zotero.org/#$HOST_ST#g" resource/config.js; \
        sed -i "s#https://www.zotero.org/#$HOST_DS#g" resource/config.js; \
        sed -i "s#https://zoteroproxycheck.s3.amazonaws.com/test##g" resource/config.js

ENV NODE_OPTIONS=--openssl-legacy-provider
ARG MLW=w
RUN npm install
RUN npm run build

RUN /bin/bash -c "./app/scripts/fetch_xulrunner -p $MLW"
RUN ./app/scripts/dir_build -p $MLW

RUN tar cjf /usr/src/app/out.tar.bz2 /usr/src/app/client/zotero-client/app/staging

FROM scratch AS export-stage
COPY --from=intermediate /usr/src/app/out.tar.bz2 .

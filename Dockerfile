#
# Builder
#
FROM golang:1.14-alpine3.11 AS builder
# process wrapper
RUN apk upgrade --update && apk add bash curl git && \
    go get -v github.com/abiosoft/parent && \
    curl https://getcaddy.com | bash -s personal http.cache,http.cors,http.expires,http.git,http.realip

FROM alpine:3.11
# process wrapper
LABEL maintainer "Steve Q qstevo@outlook.com"

# V2RAY
ARG TZ="America/Los_Angeles"

ENV TZ ${TZ}
ENV V2RAY_VERSION v4.23.1
ENV V2RAY_LOG_DIR /var/log/v2ray
ENV V2RAY_CONFIG_DIR /etc/v2ray/
ENV V2RAY_DOWNLOAD_URL https://github.com/v2ray/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip

RUN apk upgrade --update \
    && apk add \
        bash \
        tzdata \
        curl \
    && mkdir -p \ 
        ${V2RAY_LOG_DIR} \
        ${V2RAY_CONFIG_DIR} \
        /tmp/v2ray \
    && curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip ${V2RAY_DOWNLOAD_URL} \
    && pwd \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /usr/bin \
    && mv /tmp/v2ray/v2ctl /usr/bin \
    && mv /tmp/v2ray/vpoint_vmess_freedom.json /etc/v2ray/config.json \
    && chmod +x /usr/bin/v2ray \
    && chmod +x /usr/bin/v2ctl \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /tmp/v2ray /var/cache/apk/*

# ADD entrypoint.sh /entrypoint.sh
WORKDIR /srv
# node
# install node 
RUN apk add --no-cache util-linux && apk add --update nodejs nodejs-npm
COPY package.json /srv/package.json
RUN  npm install
COPY  v2ray.js /srv/v2ray.js

ARG version="1.0.5"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="false"

RUN apk add --no-cache openssh-client git

# install caddy
COPY --from=builder /usr/local/bin/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins


VOLUME /root/.caddy /srv
# WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html
# COPY package.json /etc/package.json
# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent
ADD caddy.sh /caddy.sh
EXPOSE 443 80
ENTRYPOINT ["/caddy.sh"]
# CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]

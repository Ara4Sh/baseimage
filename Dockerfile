FROM alpine:3.3
MAINTAINER Arash Shams <xsysxpert@gmail.com>

# Setting up glibc
RUN ALPINE_GLIBC_BASE_URL="https://github.com/andyshinn/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.23-r1" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/andyshinn.rsa.pub" \
        -O "/etc/apk/keys/andyshinn.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/andyshinn.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    apk del build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

# Setting up Timezone
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime \
    && echo "Asia/Tehran" >  /etc/timezone \
    && apk del tzdata

# Setting up S6 overlay
COPY rootfs /
RUN apk add --no-cache wget && \
    S6_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download" && \
    S6_PACKAGE_VERSION="v1.17.2.0" && \
    S6_PACKAGE_NAME="s6-overlay-amd64.tar.gz" && \
    wget "$S6_BASE_URL/$S6_PACKAGE_VERSION/$S6_PACKAGE_NAME" --no-check-certificate -O /tmp/s6-overlay.tar.gz && \
    tar xvfz /tmp/s6-overlay.tar.gz -C / && \
    rm -f /tmp/s6-overlay.tar.gz

# Setting up Go-dnsmasq
RUN apk add --no-cache bind-tools
RUN GODNSMASQ_BASE_URL="https://github.com/janeczku/go-dnsmasq/releases/download" && \
    GODNSMASQ_VERSION="1.0.5" && \
    GODNSMASQ_NAME="go-dnsmasq-min_linux-amd64" && \
    wget "$GODNSMASQ_BASE_URL/$GODNSMASQ_VERSION/$GODNSMASQ_NAME" -o /bin/go-dnsmasq && \
    chmod +x /bin/go-dnsmasq

# Setting up Environment
ENV LANG=C.UTF-8
ENV TERM=xterm

# Cleaning up
RUN rm -rf /var/cache/apk/*

# Entrypoint and CMD
ENTRYPOINT ["/init"]
CMD []

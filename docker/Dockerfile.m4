FROM alpine:3.6

# envsubst (gettext is very big! install only binary & dependency)
RUN apk add --no-cache libintl gettext && \
	cp /usr/bin/envsubst /usr/local/bin/envsubst && \
	apk del gettext

# Runtime libraries
RUN apk add --no-cache librdkafka jansson libpcap

define(builddeps,bash build-base ca-certificates librdkafka-dev \
		jansson-dev libpcap-dev libarchive-tools openssl)dnl
define(releasefiles,
	pmacct-*/src/sfacctd docker/release/sfacctd-start.sh \
	docker/release/sfacctd.txt.env)dnl
dnl
ifelse(version,devel,
RUN apk add --no-cache builddeps && update-ca-certificates,
COPY releasefiles /app/
ENTRYPOINT /app/sfacctd-start.sh)

WORKDIR /app

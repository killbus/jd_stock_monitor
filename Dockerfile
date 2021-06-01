FROM alpine:latest

COPY entrypoint.sh /entrypoint.sh

RUN set -eux; \
    \
    apk add --no-cache \
        bash \
        curl \
        jq \
    ; \
    \
    chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
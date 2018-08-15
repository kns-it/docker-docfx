FROM alpine:latest as build

ARG DOCFX_VERSION=2.38

RUN apk add -U wget unzip && \
    mkdir -p /tmp/docfx && \
    wget https://github.com/dotnet/docfx/releases/download/v${DOCFX_VERSION}/docfx.zip -O /tmp/docfx.zip && \
    unzip /tmp/docfx.zip -d /tmp/docfx

FROM mono:5.14

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DocFX" \
      org.label-schema.description="DocFX CLI Docker replacement" \
      org.label-schema.url="https://github.com/kns-it/docker-docfx" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/kns-it/docker-docfx" \
      org.label-schema.vendor="KNS" \
      org.label-schema.version=$DOCFX_VERSION \
      org.label-schema.schema-version="1.0" \
      maintainer="sebastian.kurfer@kns-it.de"

RUN adduser \
        --home /nonexistent \
        --shell /bin/false \
        --no-create-home \
        --gecos "" \
        --disabled-password \
        --disabled-login \
        docfx

# Copy downloaded and extracted DocFX sources to runtime container
COPY --from=build --chown=docfx:docfx /tmp/docfx /opt/docfx

# Add script to mimic docfx executable
ADD docfx /usr/bin/docfx

# set user-context to unpriviledged user
USER docfx

# Default port for docfx serve
EXPOSE 8080

ENTRYPOINT ["/usr/bin/docfx"]
FROM alpine:latest as build

ARG DOCFX_VERSION=2.44

RUN apk add -U wget unzip && \
    mkdir -p /tmp/docfx && \
    wget https://github.com/dotnet/docfx/releases/download/v${DOCFX_VERSION}/docfx.zip -O /tmp/docfx.zip && \
    unzip /tmp/docfx.zip -d /tmp/docfx

FROM mono:5.20

ARG BUILD_DATE
ARG VCS_REF

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


RUN apt-get update && \
    apt-get install -y \
                    --no-install-recommends \
                    --no-install-suggests \
		    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    adduser \
        --home /nonexistent \
        --shell /bin/false \
        --no-create-home \
        --gecos "" \
        --disabled-password \
        --disabled-login \
        docfx

# Copy downloaded and extracted DocFX sources to runtime container
COPY --from=build --chown=docfx:docfx /tmp/docfx /opt/docfx

# Install SQLitePCLRaw DLL because it's missing in Mono distribution
RUN nuget install -OutputDirectory /tmp SQLitePCLRaw.core -ExcludeVersion && \
    mv /tmp/SQLitePCLRaw.core/lib/net45/SQLitePCLRaw.core.dll /opt/docfx/ && \
    rm -rf /tmp/SQLitePCLRaw.core && \
    chown -R docfx:docfx /opt/docfx

# Add script to mimic docfx executable
ADD docfx /usr/bin/docfx

# set user-context to unpriviledged user
USER docfx

# Default port for docfx serve
EXPOSE 8080

ENTRYPOINT ["/usr/bin/docfx"]

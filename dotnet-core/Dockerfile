FROM alpine:latest as build

ARG DOCFX_VERSION=2.40.7

RUN apk add -U wget unzip gnupg && \
    mkdir -p /tmp/docfx && \
    wget https://github.com/dotnet/docfx/releases/download/v${DOCFX_VERSION}/docfx.zip -O /tmp/docfx.zip && \
    unzip /tmp/docfx.zip -d /tmp/docfx && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.asc.gpg && \
    wget https://packages.microsoft.com/config/debian/9/prod.list -O /tmp/prod.list

FROM mono:5.18

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DocFX including DotNET Core" \
      org.label-schema.description="DocFX CLI Docker replacement - includes DotNET Core distribution" \
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
		    git apt-transport-https && \
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
COPY --from=build /tmp/microsoft.asc.gpg /etc/apt/trusted.gpg.d/microsoft.asc.gpg
COPY --from=build /tmp/prod.list /etc/apt/sources.list.d/microsoft-prod.list

# Install .NET Core SDK
RUN rm -f /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y \
                    --no-install-recommends \
                    --no-install-suggests \
		    dotnet-sdk-2.2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 


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

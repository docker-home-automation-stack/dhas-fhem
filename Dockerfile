ARG ARCH="amd64"
ARG PLATFORM="linux"
ARG TAG_ROLLING="latest"
FROM fhem/fhem-${ARCH}_${PLATFORM}:${TAG_ROLLING}

# Arguments to instantiate as variables
ARG ARCH
ARG PLATFORM
ARG TAG_ROLLING
ARG TAG=""
ARG BUILD_DATE=""
ARG IMAGE_VCS_REF=""
ARG VCS_REF=""
ARG IMAGE_VERSION=""

# Re-usable variables during build
ARG L_AUTHORS="Julian Pawlowski"
ARG L_URL="https://hub.docker.com/r/homeautomationstack/dhas-fhem-${ARCH}_${PLATFORM}"
ARG L_USAGE="https://github.com/docker-home-automation-stack/dhas-fhem/blob/${IMAGE_VCS_REF}/README.md"
ARG L_VCS_URL="https://github.com/docker-home-automation-stack/dhas-fhem/"
ARG L_VENDOR="Docker Home Automation Stack"
ARG L_LICENSES="MIT"
ARG L_TITLE="dhas-fhem-${ARCH}_${PLATFORM}"
ARG L_DESCR="Custom FHEM Docker image for Docker Home Automation Stack."

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.authors=${L_AUTHORS}
LABEL org.opencontainers.image.url=${L_URL}
LABEL org.opencontainers.image.documentation=${L_USAGE}
LABEL org.opencontainers.image.source=${L_VCS_URL}
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL org.opencontainers.image.revision=${IMAGE_VCS_REF}
LABEL org.opencontainers.image.vendor=${L_VENDOR}
LABEL org.opencontainers.image.licenses=${L_LICENSES}
LABEL org.opencontainers.image.title=${L_TITLE}
LABEL org.opencontainers.image.description=${L_DESCR}

ENV PKI_GROUP ${PKI_GROUP:-pki}
ENV PKI_GROUP_ID ${PKI_GROUP_ID:-40443}

RUN echo "org.opencontainers.image.created=${BUILD_DATE}\norg.opencontainers.image.authors=${L_AUTHORS}\norg.opencontainers.image.url=${L_URL}\norg.opencontainers.image.documentation=${L_USAGE}\norg.opencontainers.image.source=${L_VCS_URL}\norg.opencontainers.image.version=${IMAGE_VERSION}\norg.opencontainers.image.revision=${IMAGE_VCS_REF}\norg.opencontainers.image.vendor=${L_VENDOR}\norg.opencontainers.image.licenses=${L_LICENSES}\norg.opencontainers.image.title=${L_TITLE}\norg.opencontainers.image.description=${L_DESCR}" > /image_info.dhas-fhem

COPY ./src/post-init.sh /post-init.sh
COPY ./src/fhem-merge-config.pl /fhem-merge-config.pl
COPY ./src/ /src/

EXPOSE 7072 8083 8084 9093 9094

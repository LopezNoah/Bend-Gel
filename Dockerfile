FROM debian:bookworm-slim

ENV BEND_HOME=/opt/bend \
    BEND_NO_TELEMETRY=1 \
    PATH=/opt/bend/bin:${PATH}

# Bend is installed in the image, never on the host. The installer verifies
# the release archive checksum before placing it under BEND_HOME.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates clang curl \
    && curl -fsSL https://bend-lang.com/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin bend

WORKDIR /workspace
COPY --chown=bend:bend . /workspace
COPY container/run-checks.sh /usr/local/bin/run-checks
RUN chmod 0555 /usr/local/bin/run-checks

USER bend
ENTRYPOINT ["/usr/local/bin/run-checks"]

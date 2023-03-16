FROM debian:bullseye-slim

RUN apt update && apt install -y --no-install-recommends cloud-init && apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# TODO: add env exclusions (cf. "'defer' was unexpected")
ENTRYPOINT [ "/usr/bin/cloud-init" ]
CMD [ "--help" ]

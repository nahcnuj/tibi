ARG VARIANT="11"
FROM mcr.microsoft.com/vscode/devcontainers/base:debian-${VARIANT}

RUN apt-get -y update \
 && apt-get install -y \
      gnupg2 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER vscode

COPY lean-toolchain .
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain `cat lean-toolchain` \
 && echo 'export PATH=$PATH:~/.elan/bin' >>~/.bashrc \
 && ~/.elan/bin/elan self update

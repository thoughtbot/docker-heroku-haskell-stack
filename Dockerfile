FROM heroku/cedar:14
MAINTAINER Gabriel Berke-Williams <gabe@thoughtbot.com>

ENV LANG en_US.UTF-8
# Stack stores binaries in /root/.local/bin
ENV PATH /root/.local/bin:$PATH

# Heroku assumes we'll put everything in /app/user
RUN mkdir -p /app/user
WORKDIR /app/user

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 575159689BEFB442 \
  && echo 'deb http://download.fpcomplete.com/ubuntu trusty main' > \
    /etc/apt/sources.list.d/fpco.list \
  && apt-get update \
  && apt-get install -y stack \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy over configuration for building the app
ONBUILD COPY *.cabal .
ONBUILD COPY stack.yaml .

# Build dependencies so that if we change something later we'll have a Docker
# cache of up to this point.
ONBUILD RUN stack setup
ONBUILD RUN stack build --dependencies-only

ONBUILD COPY . /app/user

# Install the app's binaries
ONBUILD RUN stack install

# Copy in binaries
ONBUILD RUN cp /root/.local/bin/* .

# Clean up
ONBUILD RUN rm -rf /app/user/.stack-work

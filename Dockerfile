FROM ruby:2.6.5

MAINTAINER Michael Senn <michael@morrolan.ch>

EXPOSE 8080

# Used by discordrb for voice encryption, and oauth -> jwt for some other encryption
# Has to be installed as discordrb and jwt are able to handle absence of
# libsodium gracefully, but if used in combination they do not - causing
# exceptions (https://github.com/discordrb/discordrb/issues/639)
RUN apt-get update && apt-get install -y libsodium23 libsodium-dev

# Tiny Init. (Reap zombies, forward signals)
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Create non-privileged user
RUN groupadd -r lerk && useradd -r -g lerk lerk

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# Throw error if Gemfile was modified after Gemfile.lock
RUN bundle config --global frozen 1
# Installing gems before copying source allows caching of gem installation.
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install --without development
COPY . /usr/src/app

RUN chmod +x "./docker-entrypoint.sh"

USER lerk
ENTRYPOINT ["/tini", "--", "./docker-entrypoint.sh"]

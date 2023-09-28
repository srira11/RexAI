FROM ruby:3.2.1

ADD . /web-app
WORKDIR /web-app

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN bundle install

EXPOSE 3000
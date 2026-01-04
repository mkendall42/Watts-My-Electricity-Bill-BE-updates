# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.2.2
# FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base
FROM ruby:3.2.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

#For the future, if considering secrets:
# RUN --mount=type=secret,id=rails_master_key,target=rails/config/master.key SECRET_KEY_BASE_DUMMY=1 rails assets:precompile

COPY . .

EXPOSE 3000

ENV RAILS_ENV="production"

#Why do we bind to this IP on purpose?  Is it overridden later, and this is just good practice?
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

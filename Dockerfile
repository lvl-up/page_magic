FROM ruby:2.7.2-alpine

ENV APP_HOME /page_magic
RUN mkdir $APP_HOME

COPY . $APP_HOME
WORKDIR $APP_HOME

RUN apk --update --no-cache add build-base git
RUN bundle install
RUN rm -rf $APP_HOME

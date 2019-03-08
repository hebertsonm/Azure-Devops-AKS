FROM ruby:2.5.3

WORKDIR /usr/src/app

COPY app/ .
RUN bundle install

EXPOSE 4567

CMD ["ruby", "app.rb"]


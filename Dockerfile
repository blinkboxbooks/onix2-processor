FROM ruby:2.1

ADD Gemfile /src/
ADD Gemfile.lock /src/
WORKDIR /src

RUN bundle install --deployment --without development,test
ADD . /src/

CMD ["bundle", "exec", "ruby", "bin/blinkbox-onix2_processor"]
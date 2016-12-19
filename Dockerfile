FROM registry.wellmatchhealth.com/newco-ruby-2.3.1

WORKDIR /srv/app
COPY Gemfile /srv/app/Gemfile
COPY Gemfile.lock /srv/app/Gemfile.lock
RUN bundle install --without development test

EXPOSE 8080

COPY . /srv/app
RUN chown -R app:app /home/app /srv/app
USER app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-p", "8080"]

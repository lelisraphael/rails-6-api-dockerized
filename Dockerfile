FROM ruby:2.7.2
WORKDIR /opt/app
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends -qq \
  nano build-essential libpq-dev locales default-mysql-client zip \
  libcurl4-gnutls-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get install -y nodejs && npm install --global yarn

RUN echo "America/Sao_Paulo" > /etc/timezone && \
  dpkg-reconfigure -f noninteractive tzdata && \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
  echo 'LANG="pt_BR.UTF-8"'>/etc/default/locale && \
  echo 'LC_ALL="pt_BR.UTF-8"'>/etc/default/locale && \
  echo 'LANGUAGE="pt_BR.UTF-8"'>/etc/default/locale && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=pt_BR.UTF-8

ENV LC_ALL=pt_BR.UTF-8
ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR.UTF-8

RUN gem install bundler -v 1.17.3
COPY ./Gemfile ./Gemfile
COPY ./Gemfile.lock ./Gemfile.lock
RUN bundle config --local build.sassc --disable-march-tune-native
RUN bundle install

COPY . /opt/app/

RUN rm -rf tmp && mkdir tmp
RUN rm -rf log && mkdir log

RUN yarn install

EXPOSE 3000
CMD rails s -b '0.0.0.0'

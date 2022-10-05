FROM ruby:2.7

RUN echo $(apt-cache search)

# Add NodeJS and Yarn repositories to apt-get
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# Installing Node 16.x
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash

# Install packages
RUN apt-get clean
RUN apt-get -qqy update \
    && apt-get install -y vim \
                          build-essential \
                          git \
                          curl \
                          locales \
                          libreadline-dev \
                          libssl-dev \
                          libsqlite3-dev \
                          wget \
                          xz-utils \
                          libcurl4-gnutls-dev \
                          libxrender1 \
                          libfontconfig1 \
                          apt-transport-https \
                          tzdata \
                          xfonts-base \
                          xfonts-75dpi \
                          yarn \
		                      python \
                          shared-mime-info \
		                      nodejs -qqy \
    && rm -rf /var/lib/apt/lists/*

# Env variables for application
ENV DB_ADAPTER=mysql2
ENV NODE_ENV=production
ENV RAILS_SERVE_STATIC_FILES=false

# Adding project files
RUN mkdir /dmphub
COPY ./ /dmphub
WORKDIR /dmphub

# Ensure its using the timezone we want
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set the default editor for the generation of rails credentials
RUN touch ~/.bashrc
RUN echo "export EDITOR=vim" >> ~/.bashrc

# Install Bundler
RUN gem install bundler -v 1.17.2
RUN mkdir pid

# Load dependencies
RUN bundle install --jobs 20 --retry 5

# Install and run Yarn
RUN rm -rf node_modules
RUN yarn --frozen-lockfile --production

# expose correct ports
#   25 - email server
#   80 and 443 - HTTP traffic
#   3306 - database server
EXPOSE 25 80 443 3306

CMD ["ruby", "bin/setup.rb"]

# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~>2.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Our homegrown artisinal SSM gem
gem 'uc3-ssm', git: 'https://github.com/CDLUC3/uc3-ssm', branch: '0.3.1'

# A library (owned by UC3) that retrieves an citation for the specified DOI
# https://github.com/CDLUC3/uc3-citation
gem 'uc3-citation'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
# Devise is a flexible authentication solution for Rails based on Warden.
gem 'devise'
# Bit fields for ActiveRecord
gem 'flag_shih_tzu'
# A Sass-powered version of FontAwesome for your Ruby projects and plays nicely
# with Ruby on Rails, Compass, Sprockets, etc.
gem 'font-awesome-sass', '~> 5.13.0'
# Makes http fun again! Ain't no party like a httparty, because a httparty don't stop.
gem 'httparty'
# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard.
gem 'jwt'
# A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for
# modern web app frameworks and ORMs
gem 'kaminari'

# This is a meta-distribution of RDF.rb including all currently available and usable
# parsing/serialization extensions, intended to make producing and consuming Linked Data
# with Ruby as quick & easy as possible.
# gem 'linkeddata'

# A simple, fast Mysql library for Ruby, binding to libmysql (https://github.com/brianmario/mysql2)
gem 'mysql2' # , '~> 0.4.10'
# OmniAuth is a library that standardizes multi-provider authentication for web applications.
gem 'omniauth', '~> 1.9'
# ORCID OAuth 2.0 Strategy for the OmniAuth Ruby authentication framework.
gem 'omniauth-orcid'
# Fix for security issue in omniauth: https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
gem 'omniauth-rails_csrf_protection'
# This plugin adds helpers for the reCAPTCHA API.
gem 'recaptcha'
# A simple HTTP and REST client for Ruby, inspired by the Sinatra's microframework style of specifying
# actions: get, put, post, delete.
gem 'rest-client'
# Serrano is a low level client for Crossref APIs
# gem 'serrano'
# REALLY JUST A LIST OF STOPWORDS WITH SOME HELPERS
gem 'stopwords'
# A collection of text algorithms (http://github.com/threedaymonk/text)
gem 'text'
# Capistrano Deployment
gem 'capistrano', '~> 3.10', require: false
# gem 'capistrano3-puma', require: false
gem 'capistrano-rails', '~> 1.3', require: false
# Protect your Rails and Rack apps from bad clients. Rack::Attack lets you easily decide when
# to allow, block and throttle based on properties of the request.
gem 'rack-attack'

group :development, :test do
  # Add a comment summarizing the current schema to the top or bottom of each of your models and factories
  gem 'annotate'
  # Security vulnerability scanner for Ruby on Rails. (http://brakemanscanner.org)
  gem 'brakeman'
  # Call 'byebug' anywhere in the code to stop execution and get a
  # debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # factory_bot
  gem 'factory_bot'
  # Easily generate fake data (https://github.com/stympy/faker)
  gem 'faker'
  # Mocking and stubbing library (http://gofreerange.com/mocha/docs)
  gem 'mocha', require: false
  # rspec-rails brings the RSpec testing framework to Ruby on Rails
  # as a drop-in alternative to its default testing framework, Minitest.
  gem 'rspec-rails'
  # RuboCop is a Ruby static code analyzer and code formatter.
  gem 'rubocop'
  # Performance optimization analysis for your projects, as an extension to RuboCop.
  gem 'rubocop-performance'
  # Making tests easy on the fingers and eyes (https://github.com/thoughtbot/shoulda)
  gem 'shoulda', require: false
  # Library for stubbing HTTP requests in Ruby. (http://github.com/bblimke/webmock)
  gem 'webmock'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  # Strategies for cleaning databases.  Can be used to ensure a clean state
  # for testing. (http://github.com/DatabaseCleaner/database_cleaner)
  gem 'database_cleaner'
  # Support for controller tests
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

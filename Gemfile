# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
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

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
# Devise is a flexible authentication solution for Rails based on Warden.
gem 'devise'
# Doorkeeper introduce OAuth 2 provider functionality to your Rails application.
gem 'doorkeeper'
# Doorkeeper JWT adds JWT token support to the Doorkeeper OAuth library.
gem 'doorkeeper-jwt'
# Makes http fun again! Ain't no party like a httparty, because a httparty don't stop.
gem 'httparty'
# A simple, fast Mysql library for Ruby, binding to libmysql (https://github.com/brianmario/mysql2)
gem 'mysql2', '~> 0.4.10'
# OmniAuth is a library that standardizes multi-provider authentication for web applications.
gem 'omniauth'
# ORCID OAuth 2.0 Strategy for the OmniAuth Ruby authentication framework.
gem 'omniauth-orcid'
# This plugin adds helpers for the reCAPTCHA API.
gem 'recaptcha'
# A simple HTTP and REST client for Ruby, inspired by the Sinatra's microframework style of specifying
# actions: get, put, post, delete.
gem 'rest-client'
# Serrano is a low level client for Crossref APIs
gem 'serrano'

group :development, :test do
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

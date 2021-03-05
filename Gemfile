# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'bcrypt'
gem 'rails'
gem 'sqlite3'

group :rubocop do
  gem 'rubocop', '~> 0.87.0'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'argon2'
gem 'bcrypt'
gem 'rails'
gem 'sqlite3'

group :rubocop do
  gem 'rubocop'
  gem 'rubocop-performance'
  # TODO: Unclear if rubocop-rails provides any real value. Re-add or remove
  #       comment after determining if it is valuable.
  # gem 'rubocop-rails'
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
  gem 'timecop'
end

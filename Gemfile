# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development, :test do
  gem "actionview"
  gem "irb"
  gem "pry-byebug"
  gem "rake", "~> 13.3"
  gem "rdoc"
  gem "ruby_audit"
  gem "standard"
end

group :test do
  gem "rspec"
  gem "simplecov"
end

platforms :mri do
  gem "rbs", "~> 3.9"
  gem "steep", "~> 1.10"
end

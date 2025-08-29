# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nameplate/version"

Gem::Specification.new do |spec|
  spec.name = "nameplate"
  spec.version = NamePlate::VERSION
  spec.authors = ["Anthony Lombardi"]
  spec.email = ["iam@t0nylombardi.com"]
  spec.description = "Gem for creating avatars from user's name"
  spec.summary = "Create nice initials avatars from your users usernames"
  spec.homepage = "https://github.com/t0nylombardi/nameplate"
  spec.license = "MIT"
  spec.files = Dir.glob("lib/**/*") + %w[README.md CHANGELOG.md Lato-Light]
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_magick", "~> 5.3"
  spec.add_dependency "rbs", "~> 3.9", ">= 3.9.4"
end

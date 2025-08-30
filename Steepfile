# Steep configuration

target :lib do
  # RBS signatures live here
  signature "sig"

  # Type-check Ruby sources here
  check "lib"

  # You can add libraries once you install RBS collections for gems
  # via `bundle exec rbs collection init && install`, then uncomment:
  library "pathname", "fileutils", "securerandom", "digest", "base64"
  library "logger", "rspec", "actionview"
end

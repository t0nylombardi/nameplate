# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

SIG_DIR = "sig"

RSpec::Core::RakeTask.new(:spec)

task default: %i[specstandard]
task :standard do
  Standard::RakeTask.new.execute
end

namespace :rbs do
  desc "Remove generated RBS files"
  task :clean do
    sh "rm -rf #{SIG_DIR}"
  end

  desc "Generate RBS files mirroring lib/ into sig/"
  task :generate do
    sh "mkdir -p #{SIG_DIR}"
    ruby_files = Dir.glob("lib/**/*.rb")

    ruby_files.each do |rb|
      out = File.join(SIG_DIR, rb.sub(%r{\Alib/}, "").sub(/\.rb\z/, ".rbs"))
      out_dir = File.dirname(out)
      sh "mkdir -p #{out_dir}"
      sh "bundle exec rbs prototype rb #{rb} > #{out}"
    end
    puts "Generated #{ruby_files.size} RBS file(s) under #{SIG_DIR}/"
  end
end

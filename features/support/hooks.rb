# frozen_string_literal: true

# Hooks for the Cucumber scenarios.

Before do
  # Make temporary directory for cltester.
  lib_dir = File.expand_path('../..', __dir__)
  @cltester_dir = File.expand_path('temp/cltester', lib_dir)
  Dir.mkdir(@cltester_dir) unless Dir.exist?(@cltester_dir)
end

After do
  # Delete any files and subdirectories remaining in the cltester dir.
  puts "After hook: #{@cltester_dir}"
end

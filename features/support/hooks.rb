# frozen_string_literal: true

# Hooks for the Cucumber scenarios.

Before do
  # Make temporary directory for cltester.
  lib_dir = File.expand_path('../..', __dir__)
  @cltester_dir = File.expand_path('temp/cltester', lib_dir)
  FileUtils.mkdir_p(@cltester_dir)
  # Change to the temporary directory
  Dir.chdir(@cltester_dir)
  # Ensure the directory is clean
  FileUtils.rm(Dir.glob('./*'))
  # Ensure that the global variable for run status is initialized false.
  @successful_run = false
end

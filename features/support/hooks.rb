# frozen_string_literal: true

# Hooks for the Cucumber scenarios.

Before do
  # Make temporary directory for cltester.
  @cltester_dir = File.join(__dir__, '../..', 'temp/cltester')
  FileUtils.mkdir_p(@cltester_dir)
  # Change to the temporary directory
  Dir.chdir(@cltester_dir)
  # Ensure the directory is clean
  FileUtils.rm_r(Dir.glob('./*'), secure: true)
  # Ensure that the global variable for run status is initialized false.
  @successful_run = false
end

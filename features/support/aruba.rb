# frozen_string_literal: true

# Author: Bruce Tesar

# Allows Cucumber to use the Aruba gem, which has some pre-defined step
# definitions that are useful for testing command line programs.
# NOTE: the gem ffi must be installed in order for aruba to work on Windows;
# this dependency is not automatically managed by gem itself (I don't know
# why).
require 'aruba/cucumber'

# Set the timeout for an Aruba step. The default is 15 seconds, which is
# too low for typology-cranking programs like odl.
Aruba.configure do |config|
  config.exit_timeout = 20 # 20 seconds
end

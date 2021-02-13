# frozen_string_literal: true

# Author: Bruce Tesar

# Allows Cucumber to use the Aruba gem, which has some pre-defined step
# definitions that are useful for testing command line programs.
# NOTE: the gem ffi must be installed in order for aruba to work on Windows;
# this dependency is not automatically managed by gem itself (I don't know
# why).
require 'aruba/cucumber'

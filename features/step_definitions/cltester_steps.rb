# frozen_string_literal: true

# Cucumber steps used when testing command line applications.
# The step texts borrow heavily from the ruby gem Aruba, which I
# previously used until it stopped being compatible with MS Windows.
# Author: Bruce Tesar

Given(/^(?:a|the) file(?: named)? "([^"]*)" with:$/) do |file_name,
  file_content|
  path = File.join(@cltester_dir, file_name)
  File.write(path, file_content)
end

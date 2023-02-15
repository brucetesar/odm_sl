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

When(/^I run `([^`]*)`$/) do |exec_file|
  # Pipe the STDOUT to a file
  cmd = "#{exec_file} > cltester_STDOUT.txt"
  # system() runs the given command in a subshell, returning
  # a boolean indicating if execution was successful or not.
  @successful_run = system(cmd)
end

Then(/^it should (pass|fail)$/) do |pass_fail|
  if pass_fail == 'pass'
    expect(@successful_run).to be true
  else
    expect(@successful_run).not_to be true
  end
end

Then(/^STDOUT should contain:$/) do |expected|
  actual = File.read('cltester_STDOUT.txt')
  expect(actual).to include(expected)
end

Then(/^STDOUT should be exactly:$/) do |expected|
  actual = File.read('cltester_STDOUT.txt')
  # End expected with a newline, to match captured STDOUT.
  expected = expected << "\n"
  expect(actual).to eq(expected)
end

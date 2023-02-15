# frozen_string_literal: true

# Author: Bruce Tesar

Given(/^that file "([^"]*)" does not exist$/) do |filename|
  File.delete(filename) if File.exist?(filename)
  expect(File.exist?(filename)).to be false
end

Then(/^the file "([^"]*)" is produced$/) do |created_file|
  expect(File.exist?(created_file)).to be true
end

Then(/^"([^"]*)" is identical to "([^"]*)"$/) do |generated_file, expected_file|
  generated = IO.read(generated_file) # reads the entire file into a string
  expected = IO.read(expected_file)
  expect(generated).to eq(expected)
end

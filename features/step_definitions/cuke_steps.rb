# frozen_string_literal: true

# Author: Bruce Tesar

Then(/^"([^"]*)" is identical to "([^"]*)"$/) do |generated_file, expected_file|
  generated = File.read(generated_file) # reads the entire file into a string
  expected = File.read(expected_file)
  expect(generated).to eq(expected)
end

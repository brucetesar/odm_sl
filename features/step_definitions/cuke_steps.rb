# frozen_string_literal: true

# Author: Bruce Tesar

Then(/^"([^"]*)" is identical to "([^"]*)"$/) do |generated_file, expected_file|
  generated = IO.read(generated_file) # reads the entire file into a string
  expected = IO.read(expected_file)
  expect(generated).to eq(expected)
end

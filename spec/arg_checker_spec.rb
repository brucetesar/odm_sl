# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'arg_checker'
require 'stringio'

RSpec.describe ArgChecker do
  let(:option_string) { '--opstr' }
  # Use StringIO as a test mock for $stdout.
  let(:err_output) { StringIO.new }

  before do
    @checker = described_class.new(err_output: err_output)
  end

  context 'when given a valid argument' do
    let(:arg) { 'argvalue' }
    let(:arg_values) { %w[firstarg argvalue another] }

    it 'indicates the arg is given' do
      expect(@checker.arg_given?(arg, option_string)).to be true
    end

    it 'indicates the arg is valid' do
      expect(@checker.arg_valid?(arg, arg_values, option_string)).to be true
    end

    it 'does not write an error message' do
      expect(err_output.string).to eq ''
    end
  end

  context 'when given a nil argument' do
    let(:arg) { nil }
    let(:arg_values) { %w[firstarg argvalue another] }

    it 'indicates the arg is not given' do
      expect(@checker.arg_given?(arg, option_string)).to be false
    end

    it 'indicates the arg is invalid' do
      expect(@checker.arg_valid?(arg, arg_values, option_string)).to be false
    end

    it 'writes an error message for missing arg' do
      @checker.arg_given?(arg, option_string)
      expect(err_output.string).to eq\
        "ERROR: missing command line option #{option_string}.\n"
    end

    it 'writes an error message for invalid arg' do
      @checker.arg_valid?(arg, arg_values, option_string)
      expect(err_output.string).to eq\
        "ERROR: missing command line option #{option_string}.\n"
    end
  end

  context 'when given an invalid argument' do
    let(:arg) { 'invalid' }
    let(:arg_values) { %w[firstarg argvalue another] }

    it 'indicates the arg is given' do
      expect(@checker.arg_given?(arg, option_string)).to be true
    end

    it 'indicates the arg is invalid' do
      expect(@checker.arg_valid?(arg, arg_values, option_string)).to be false
    end

    it 'does not write an error message for missing arg' do
      @checker.arg_given?(arg, option_string)
      expect(err_output.string).to eq ''
    end

    it 'writes an error message for invalid arg' do
      msg1 = "ERROR: invalid #{option_string} value #{arg}.\n"
      msg2 = "Value must be one of #{arg_values.join(', ')}\n"
      @checker.arg_valid?(arg, arg_values, option_string)
      expect(err_output.string).to eq "#{msg1}#{msg2}"
    end
  end
end

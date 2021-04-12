# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'arg_checker'

RSpec.describe 'ArgChecker' do
  let(:option_string){ '--opstr' }
  before(:example) do
    @checker = ArgChecker.new
  end

  context 'when given a valid argument' do
    let(:arg){ 'argvalue' }
    let(:arg_values){ ['firstarg', 'argvalue', 'another'] }
    before(:example) do
    end
    it 'indicates the arg is given' do
      expect(@checker.arg_given?(arg, option_string)).to be true
    end
    it 'indicates the arg is valid' do
      expect(@checker.arg_valid?(arg, arg_values, option_string)).to be true
    end
  end

  context 'when given a nil argument' do
    let(:arg){ nil }
    let(:arg_values){ ['firstarg', 'argvalue', 'another'] }
    before(:example) do
    end
    it 'indicates the arg is not given' do
      expect(@checker.arg_given?(arg, option_string)).to be false
    end
    it 'indicates the arg is invalid' do
      expect(@checker.arg_valid?(arg, arg_values, option_string)).to be false
    end
  end

  context 'when given an invalid argument' do
    let(:arg){ 'invalid' }
    let(:arg_values){ ['firstarg', 'argvalue', 'another'] }
    before(:example) do
    end
    it 'indicates the arg is given' do
      expect(@checker.arg_given?(arg, option_string)).to be true
    end
    it 'indicates the arg is invalid' do
      expect(@checker.arg_valid?(arg, arg_values, option_string)).to be false
    end
  end
end

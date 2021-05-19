# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/error_step'
require 'otlearn/otlearn'

RSpec.describe OTLearn::ErrorStep do
  context 'with a message' do
    before do
      msg = 'Error Message'
      @err_step = described_class.new(msg)
    end

    it 'returns its message' do
      expect(@err_step.msg).to eq 'Error Message'
    end

    it 'returns its step type' do
      expect(@err_step.step_type).to eq OTLearn::ERROR
    end

    it 'indicates that learning failed' do
      expect(@err_step).not_to be_all_correct
    end
  end
end

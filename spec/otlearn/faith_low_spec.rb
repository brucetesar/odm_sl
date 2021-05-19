# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/faith_low'
require 'constraint'

RSpec.describe OTLearn::FaithLow do
  let(:con) { instance_double(Constraint, 'constraint') }

  before do
    @kind = described_class.new
  end

  context 'with a faithfulness constraint' do
    before do
      allow(con).to receive(:faithfulness?).and_return(true)
    end

    it 'returns true' do
      expect(@kind.member?(con)).to be true
    end
  end

  context 'with a non-faithfulness constraint' do
    before do
      allow(con).to receive(:faithfulness?).and_return(false)
    end

    it 'returns false' do
      expect(@kind.member?(con)).to be false
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/mark_low'
require 'constraint'

RSpec.describe OTLearn::MarkLow do
  let(:con) { instance_double(Constraint, 'constraint') }

  before do
    @kind = described_class.new
  end

  context 'with a markedness constraint' do
    before do
      allow(con).to receive(:markedness?).and_return(true)
    end

    it 'returns true' do
      expect(@kind.member?(con)).to be true
    end
  end

  context 'with a non-markedness constraint' do
    before do
      allow(con).to receive(:markedness?).and_return(false)
    end

    it 'returns false' do
      expect(@kind.member?(con)).to be false
    end
  end
end

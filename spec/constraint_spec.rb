# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'constraint'
require 'support/named_constraint_shared_examples'

RSpec.describe Constraint do
  let(:cand1) { double('cand1') }
  let(:cand2) { double('cand2') }
  let(:content1) { double('content1') }

  context 'when markedness' do
    before do
      allow(content1).to receive(:eval_candidate).and_return(2)
      allow(content1).to receive(:eval_candidate).with(cand1).and_return(7)
      @constraint =
        described_class.new('Constraint1', Constraint::MARK, content1)
    end

    it_behaves_like 'named constraint' do
      let(:con) \
        { described_class.new('Constraint1', Constraint::MARK, content1) }
      let(:eq_con) \
        { described_class.new('Constraint1', Constraint::MARK, content1) }
      let(:noteq_con) \
        { described_class.new('NotCon1', Constraint::MARK, content1) }
    end

    it 'returns its name' do
      expect(@constraint.name).to eq('Constraint1')
    end

    it 'is a markedness constraint' do
      expect(@constraint.markedness?).to be true
    end

    it 'is not a faithfulness constraint' do
      expect(@constraint.faithfulness?).to be false
    end

    it 'returns a to_s string of its name' do
      expect(@constraint.to_s).to eq('Constraint1')
    end

    it 'assesses violations to a candidate' do
      expect(@constraint.eval_candidate(cand1)).to eq(7)
    end

    it 'assesses different violations to a different candidate' do
      expect(@constraint.eval_candidate(cand2)).to eq(2)
    end
  end

  context 'when faithfulness' do
    before do
      allow(content1).to receive(:eval_candidate).and_return(0)
      @constraint = described_class.new('Cname', Constraint::FAITH, content1)
    end

    it_behaves_like 'named constraint' do
      let(:con) \
        { described_class.new('Constraint1', Constraint::FAITH, content1) }
      let(:eq_con) \
        { described_class.new('Constraint1', Constraint::FAITH, content1) }
      let(:noteq_con) \
        { described_class.new('NotCon1', Constraint::FAITH, content1) }
    end

    it 'returns its name' do
      expect(@constraint.name).to eq('Cname')
    end

    it 'is not a markedness constraint' do
      expect(@constraint.markedness?).to be false
    end

    it 'is a faithfulness constraint' do
      expect(@constraint.faithfulness?).to be true
    end

    it 'returns a to_s string of Cname' do
      expect(@constraint.to_s).to eq('Cname')
    end
  end

  context 'with an invalid constraint type' do
    before do
      allow(content1).to receive(:eval_candidate).and_return(2)
    end

    it 'raises a RuntimeError' do
      expect { described_class.new('FCon', 'OTHER', content1) }.to\
        raise_error(RuntimeError)
    end
  end
end

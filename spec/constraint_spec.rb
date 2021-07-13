# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'constraint'
require 'support/named_constraint_shared_examples'

RSpec.describe Constraint do
  let(:cand1) { double('cand1') }
  let(:cand2) { double('cand2') }
  let(:content) { double('content') }
  let(:eq_content) { double('eq_content') }
  let(:noteq_content) { double('noteq_content') }

  context 'when markedness' do
    before do
      allow(content).to receive(:name).and_return('Constraint1')
      allow(content).to receive(:type).and_return(Constraint::MARK)
      allow(content).to receive(:eval_candidate).and_return(2)
      allow(content).to receive(:eval_candidate).with(cand1).and_return(7)
      allow(eq_content).to receive(:name).and_return('Constraint1')
      allow(eq_content).to receive(:type).and_return(Constraint::MARK)
      allow(noteq_content).to receive(:name).and_return('NotCon1')
      allow(noteq_content).to receive(:type).and_return(Constraint::MARK)
      @constraint =
        described_class.new(content)
    end

    it_behaves_like 'named constraint' do
      let(:con) { described_class.new(content) }
      let(:eq_con) { described_class.new(eq_content) }
      let(:noteq_con) { described_class.new(noteq_content) }
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
      allow(content).to receive(:name).and_return('Cname')
      allow(content).to receive(:type).and_return(Constraint::FAITH)
      allow(content).to receive(:eval_candidate).and_return(0)
      allow(eq_content).to receive(:name).and_return('Cname')
      allow(eq_content).to receive(:type).and_return(Constraint::FAITH)
      allow(noteq_content).to receive(:name).and_return('NotCon')
      allow(noteq_content).to receive(:type).and_return(Constraint::FAITH)
      @constraint = described_class.new(content)
    end

    it_behaves_like 'named constraint' do
      let(:con) { described_class.new(content) }
      let(:eq_con) { described_class.new(eq_content) }
      let(:noteq_con) { described_class.new(noteq_content) }
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
      allow(content).to receive(:name).and_return('FCon')
      allow(content).to receive(:type).and_return('OTHER')
      allow(content).to receive(:eval_candidate).and_return(2)
    end

    it 'raises a RuntimeError' do
      expect { described_class.new(content) }.to\
        raise_error(RuntimeError)
    end
  end
end

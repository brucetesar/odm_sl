# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'constraint'

RSpec.describe Constraint do
  let(:cand1) { double('cand1') }
  let(:cand2) { double('cand2') }
  let(:content1) { double('content1') }

  context 'when markedness with name Constraint1' do
    before do
      allow(content1).to receive(:eval_candidate).and_return(2)
      allow(content1).to receive(:eval_candidate).with(cand1).and_return(7)
      @constraint =
        described_class.new('Constraint1', Constraint::MARK, content1)
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

    it 'returns a to_s string of Constraint1' do
      expect(@constraint.to_s).to eq('Constraint1')
    end

    it 'assesses 7 violations to candidate cand1' do
      expect(@constraint.eval_candidate(cand1)).to eq(7)
    end

    it 'assesses 2 violations to candidate cand2' do
      expect(@constraint.eval_candidate(cand2)).to eq(2)
    end
  end

  context 'when faithfulness with name Cname' do
    before do
      allow(content1).to receive(:eval_candidate).and_return(0)
      @constraint = described_class.new('Cname', Constraint::FAITH, content1)
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

  context 'with a constraint' do
    before do
      @buddy1 = described_class.new('buddy', Constraint::MARK)
      @buddy2 = described_class.new('buddy', Constraint::MARK)
      @notbuddy = described_class.new('notbuddy', Constraint::MARK)
    end

    it 'is == to another constraint with the same name' do
      expect(@buddy1 == @buddy2).to be true
    end

    it 'is eql? to another constraint with the same name' do
      expect(@buddy1.eql?(@buddy2)).to be true
    end

    it 'has the same hash value as a same-named constraint' do
      expect(@buddy1.hash).to eq(@buddy2.hash)
    end

    it 'is not == to a constraint with a different name' do
      expect(@buddy1 == @notbuddy).to be false
    end

    it 'is not eql? to a constraint with a different name' do
      expect(@buddy1.eql?(@notbuddy)).to be false
    end

    it 'does not have the same hash value as a diff-named constraint' do
      expect(@buddy1.hash).not_to eq(@notbuddy.hash)
    end
  end

  context 'with a new constraint set properly to MARK' do
    it 'does not raise a RuntimeError' do
      expect { described_class.new('FCon', Constraint::MARK) }.not_to\
        raise_error
    end
  end

  context 'with a new Constraint with type set to OTHER' do
    it 'raises a RuntimeError' do
      expect { described_class.new('FCon', 'OTHER', nil) }.to\
        raise_error(RuntimeError)
    end
  end

  context 'with a new constraint with no content object' do
    before do
      @constraint = described_class.new('FCon', Constraint::MARK)
    end

    it 'raises an exception if used to evaluate a candidate' do
      expect { @constraint.eval_candidate('cand') }.to\
        raise_error(RuntimeError)
    end
  end
end

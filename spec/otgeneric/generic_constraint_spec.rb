# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/generic_constraint'
require 'constraint'
# RSpec adds spec/ to the $LOAD_PATH, so spec/support/ is visible.
require 'support/named_constraint_shared_examples'

module OTGeneric
  RSpec.describe GenericConstraint do
    before do
      @constraint = described_class.new('Con1', Constraint::MARK)
    end

    it_behaves_like 'named constraint' do
      let(:con) { described_class.new('Constraint1', Constraint::MARK) }
      let(:eq_con) { described_class.new('Constraint1', Constraint::MARK) }
      let(:noteq_con) { described_class.new('NotCon1', Constraint::MARK) }
      let(:not_a_con) { double('not_a_con') }
    end

    it 'returns its name' do
      expect(@constraint.name).to eq('Con1')
    end

    it 'is a markedness constraint' do
      expect(@constraint.markedness?).to be true
    end

    it 'is not a faithfulness constraint' do
      expect(@constraint.faithfulness?).to be false
    end

    it 'returns a to_s string of its name' do
      expect(@constraint.to_s).to eq('Con1')
    end

    it 'raises an exception if used to evaluate a candidate' do
      expect { @constraint.eval_candidate('cand') }.to\
        raise_error(RuntimeError)
    end
  end
end

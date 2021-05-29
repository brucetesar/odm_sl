# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'ranking_bias_all_high'

RSpec.describe RankingBiasAllHigh do
  let(:rcd) { double('rcd') }
  let(:con1) { double('constraint1') }
  let(:con2) { double('constraint2') }

  before do
    @rankable = [con1, con2]
    @bias = described_class.new
  end

  context 'with rankable constraints' do
    before do
      @returned_constraints = @bias.choose_cons_to_rank(@rankable, rcd)
    end

    it 'returns all rankable constraints' do
      expect(@returned_constraints).to eq @rankable
    end
  end
end

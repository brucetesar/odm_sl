# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'clash_lapse/lapse'
require 'constraint'
require 'candidate'
require 'output'
require 'sl/syllable'

module ClashLapse
  RSpec.describe Lapse do
    let(:candidate) { instance_double(Candidate, 'candidate') }
    let(:output) { instance_double(Output, 'output') }
    let(:syl0) { instance_double(SL::Syllable, 'syl0') }
    let(:syl1) { instance_double(SL::Syllable, 'syl1') }
    let(:syl2) { instance_double(SL::Syllable, 'syl2') }

    before do
      allow(candidate).to receive(:output).and_return(output)
      @content = described_class.new
    end

    it 'returns the constraint name' do
      expect(@content.name).to eq 'Lapse'
    end

    it 'is a markedness constraint' do
      expect(@content.type).to eq Constraint::MARK
    end
  end
end

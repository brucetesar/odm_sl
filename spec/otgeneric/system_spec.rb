# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/system'

RSpec.describe 'OTGeneric::System' do
  let(:comp_list) { [] }
  let(:comp1) { [] }
  let(:comp2) { [] }
  let(:cand1) { double('candidate1') }
  let(:cand21) { double('candidate21') }
  let(:cand22) { double('candidate22') }
  let(:con_list) { double('constraint list') }
  let(:in1) { double('input 1') }
  let(:in2) { double('input 2') }
  before do
    allow(cand1).to receive(:constraint_list).and_return(con_list)
    allow(cand21).to receive(:constraint_list).and_return(con_list)
    allow(cand22).to receive(:constraint_list).and_return(con_list)
    allow(cand1).to receive(:input).and_return(in1)
    allow(cand21).to receive(:input).and_return(in2)
    allow(cand22).to receive(:input).and_return(in2)
    comp1 << cand1
    comp2 << cand21 << cand22
    comp_list << comp1 << comp2
    @system = OTGeneric::System.new(comp_list)
  end
  it 'returns a list of constraints' do
    expect(@system.constraints).to eq con_list
  end
  it 'returns the competition for an input' do
    expect(@system.gen(in1)).to eq comp1
  end
  it 'returns a competition that is not initial in the list' do
    expect(@system.gen(in2)).to eq comp2
  end
end

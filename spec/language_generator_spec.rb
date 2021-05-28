# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'language_generator'

RSpec.describe LanguageGenerator do
  let(:eval) { double('eval') }
  let(:hier) { double('hierarchy') }

  context 'with one competition with one optimum' do
    let(:opt1) { double('optimal1') }
    let(:comp1) { double('competition1') }

    before do
      allow(eval).to receive(:find_optima).with(comp1, hier)\
                                          .and_return([opt1])
      @comp_list = [comp1]
      @generator = described_class.new(eval)
    end

    it 'returns an array with the optimum' do
      expect(@generator.generate_language(@comp_list, hier)).to\
        contain_exactly(opt1)
    end
  end

  context 'with two competitions each with one optimum' do
    let(:opt1) { double('optimal1') }
    let(:opt2) { double('optimal2') }
    let(:comp1) { double('competition1') }
    let(:comp2) { double('competition2') }

    before do
      allow(eval).to receive(:find_optima).with(comp1, hier)\
                                          .and_return([opt1])
      allow(eval).to receive(:find_optima).with(comp2, hier)\
                                          .and_return([opt2])
      @comp_list = [comp1, comp2]
      @generator = described_class.new(eval)
    end

    it 'returns an array with both optima' do
      expect(@generator.generate_language(@comp_list, hier)).to\
        contain_exactly(opt1, opt2)
    end
  end

  context 'with two competitions, one with one optimum and one with two' do
    let(:opt1) { double('optimal1') }
    let(:opt2a) { double('optimal2a') }
    let(:opt2b) { double('optimal2b') }
    let(:comp1) { double('competition1') }
    let(:comp2) { double('competition2') }

    before do
      allow(eval).to receive(:find_optima).with(comp1, hier)\
                                          .and_return([opt1])
      allow(eval).to receive(:find_optima).with(comp2, hier)\
                                          .and_return([opt2a, opt2b])
      @comp_list = [comp1, comp2]
      @generator = described_class.new(eval)
    end

    it 'returns an array with both optima' do
      expect(@generator.generate_language(@comp_list, hier)).to\
        contain_exactly(opt1, opt2a, opt2b)
    end
  end

  context 'with an empty competition list' do
    before do
      @comp_list = []
      @generator = described_class.new(eval)
    end

    it 'returns an empty language' do
      expect(@generator.generate_language(@comp_list, hier)).to be_empty
    end
  end
end

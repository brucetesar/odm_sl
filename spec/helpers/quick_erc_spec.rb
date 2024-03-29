# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require_relative 'quick_erc'

RSpec.describe QuickErc do
  before do
    # Stub the class constants, so that the prefix described_class::
    # can be omitted in the rest of the specs.
    stub_const('ML', described_class::ML)
    stub_const('ME', described_class::ME)
    stub_const('MW', described_class::MW)
    stub_const('FL', described_class::FL)
    stub_const('FE', described_class::FE)
    stub_const('FW', described_class::FW)
  end

  context 'with input [ML,MW]' do
    before do
      @erc1 = described_class.new([ML, MW])
      @con_list = @erc1.constraint_list
      @con_names = @con_list.map(&:name)
    end

    it 'has two constraints' do
      expect(@erc1.constraint_list.size).to eq(2)
    end

    it 'has a constraint named M1' do
      expect(@con_names.include?('M1')).to be true
    end

    it 'has a constraint named M2' do
      expect(@con_names.include?('M2')).to be true
    end

    context 'with constraints M1 and M2' do
      before do
        @m1 = @con_list.find { |c| c.name == 'M1' }
        @m2 = @con_list.find { |c| c.name == 'M2' }
      end

      it 'assigns L to constraint M1' do
        expect(@erc1.l?(@m1)).to be true
      end

      it 'does not assign W to constraint M1' do
        expect(@erc1.w?(@m1)).to be false
      end

      it 'does not assign L to constraint M2' do
        expect(@erc1.l?(@m2)).to be false
      end

      it 'assigns W to constraint M2' do
        expect(@erc1.w?(@m2)).to be true
      end

      it 'has M1 as a markedness constraint' do
        expect(@m1.markedness?).to be true
      end
    end
  end

  context 'with input [ML,FW,MW]' do
    before do
      @erc1 = described_class.new([ML, FW, MW])
      @con_list = @erc1.constraint_list
      @con_names = @con_list.map(&:name)
    end

    it 'has three constraints' do
      expect(@erc1.constraint_list.size).to eq(3)
    end

    it 'has a constraint named M1' do
      expect(@con_names.include?('M1')).to be true
    end

    it 'has a constraint named F2' do
      expect(@con_names.include?('F2')).to be true
    end

    it 'has a constraint named M3' do
      expect(@con_names.include?('M3')).to be true
    end

    context 'with constraints M1, F2, and M3' do
      before do
        @m1 = @con_list.find { |c| c.name == 'M1' }
        @f2 = @con_list.find { |c| c.name == 'F2' }
        @m3 = @con_list.find { |c| c.name == 'M3' }
      end

      it 'has M1 as a markedness constraint' do
        expect(@m1.markedness?).to be true
      end

      it 'has F2 as a faithfulness constraint' do
        expect(@f2.faithfulness?).to be true
      end

      it 'has M3 as a markedness constraint' do
        expect(@m3.markedness?).to be true
      end
    end
  end
end

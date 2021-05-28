# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'erc'

RSpec.describe Erc do
  before do
    @erc = described_class.new(%w[C1 C2])
  end

  context 'with two unset constraints' do
    it 'is e for a constraint' do
      expect(@erc.e?('C1')).to be true
    end

    it 'is not W for a constraint' do
      expect(@erc.w?('C1')).not_to be true
    end

    it 'is not L for a constraint' do
      expect(@erc.l?('C1')).not_to be true
    end

    it 'to_s produces a string of the preferences' do
      expect(@erc.to_s).to eq 'C1:e C2:e'
    end
  end

  context 'with C1 set to W and C2 set to L' do
    before do
      @erc.set_w('C1')
      @erc.set_l('C2')
    end

    it 'is W for C1' do
      expect(@erc.w?('C1')).to be true
    end

    it 'is not L for C1' do
      expect(@erc.l?('C1')).not_to be true
    end

    it 'is not e for C1' do
      expect(@erc.e?('C1')).not_to be true
    end

    it 'is L for C2' do
      expect(@erc.l?('C2')).to be true
    end

    it 'is not W for C2' do
      expect(@erc.w?('C2')).not_to be true
    end

    it 'is not e for C2' do
      expect(@erc.e?('C2')).not_to be true
    end

    context 'when C1 is reset to e' do
      before do
        @erc.set_e('C1')
      end

      it 'is e for C1' do
        expect(@erc.e?('C1')).to be true
      end

      it 'is not W for C1' do
        expect(@erc.w?('C1')).not_to be true
      end

      it 'is not L for C1' do
        expect(@erc.l?('C1')).not_to be true
      end
    end
  end

  context 'with two Ercs' do
    before do
      @erc1 = described_class.new(%w[C1 C2])
      @erc2 = described_class.new(%w[C1 C2])
    end

    context 'with the same constraint preferences' do
      before do
        @erc1.set_w('C1')
        @erc2.set_w('C1')
        @erc1.set_l('C2')
        @erc2.set_l('C2')
      end

      it 'has the same hash value' do
        expect(@erc1.hash).to eq(@erc2.hash)
      end
    end

    context 'with different constraint preferences' do
      before do
        @erc1.set_w('C1')
        @erc2.set_w('C1')
        @erc1.set_l('C2')
        @erc2.set_e('C2')
      end

      it 'does not have the same hash value' do
        expect(@erc1.hash).not_to eq(@erc2.hash)
      end
    end
  end
end

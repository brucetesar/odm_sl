# frozen_string_literal: true

# Author: Bruce Tesar

require 'pas/length'

RSpec.describe PAS::Length do
  let(:length) { PAS::Length::LENGTH }
  let(:short) { PAS::Length::SHORT }
  let(:long) { PAS::Length::LONG }
  context '' do
    before(:each) do
      @length = PAS::Length.new
    end
    it 'has type LENGTH' do
      expect(@length.type).to eq length
    end
    it 'should be unset' do
      expect(@length.unset?).to be true
    end
    it 'should not be short' do
      expect(@length.short?).to be false
    end
    it 'should not be long' do
      expect(@length.long?).to be false
    end
    it 'should return a string value of length=unset' do
      expect(@length.to_s).to eq('length=unset')
    end
    it 'should accept short as a valid value' do
      expect(@length.valid_value?(short)).to be true
    end
    it 'should accept long as a valid value' do
      expect(@length.valid_value?(long)).to be true
    end
    it 'should not accept :invalid as a valid value' do
      expect(@length.valid_value?(:invalid)).to be false
    end
    it 'iterates over the feature values' do
      expect { |probe| @length.each_value(&probe) }.to\
        yield_successive_args(short, long)
    end

    context 'set to short' do
      before(:each) do
        @length.set_short
      end
      it 'should be set' do
        expect(@length.unset?).to be false
      end
      it 'should be short' do
        expect(@length.short?).to be true
      end
      it 'should not be long' do
        expect(@length.long?).to be false
      end
      it 'should return a string value of length=short' do
        expect(@length.to_s).to eq('length=short')
      end
    end

    context 'set to long' do
      before(:each) do
        @length.set_long
      end
      it 'should be set' do
        expect(@length.unset?).to be false
      end
      it 'should not be short' do
        expect(@length.short?).to be false
      end
      it 'should be long' do
        expect(@length.long?).to be true
      end
      it 'should return a string value of length=long' do
        expect(@length.to_s).to eq('length=long')
      end
    end
  end
end

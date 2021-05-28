# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'morph_word'

RSpec.describe MorphWord do
  let(:root) { double('root') }
  let(:root2) { double('root2') }
  let(:suffix1) { double('suffix1') }
  let(:prefix1) { double('prefix1') }
  let(:badmorph) { double('badmorph') }

  before do
    allow(root).to receive(:root?).and_return(true)
    allow(root).to receive(:label).and_return('root')
    allow(root2).to receive(:root?).and_return(true)
    allow(suffix1).to receive(:root?).and_return(false)
    allow(suffix1).to receive(:prefix?).and_return(false)
    allow(suffix1).to receive(:suffix?).and_return(true)
    allow(suffix1).to receive(:label).and_return('suffix1')
    allow(prefix1).to receive(:root?).and_return(false)
    allow(prefix1).to receive(:prefix?).and_return(true)
    allow(prefix1).to receive(:suffix?).and_return(false)
    allow(prefix1).to receive(:label).and_return('prefix1')
    allow(badmorph).to receive(:root?).and_return(false)
    allow(badmorph).to receive(:prefix?).and_return(false)
    allow(badmorph).to receive(:suffix?).and_return(false)
  end

  context 'when constructed without a root' do
    before do
      @mw = described_class.new
    end

    it 'contains zero morphemes' do
      expect(@mw.size).to eq 0
    end

    context 'when a root is added' do
      before do
        @result = @mw.add(root)
      end

      it 'contains one morpheme' do
        expect(@mw.size).to eq 1
      end

      it 'returns a reference to self' do
        expect(@result).to equal @mw
      end

      it 'attempting to add a second root raises a RuntimeError' do
        msg = 'MorphWord.add: Cannot add a second root.'
        expect { @mw.add(root2) }.to raise_error(RuntimeError, msg)
      end

      it 'returns a string representation of the morphword' do
        expect(@mw.to_s).to eq 'root'
      end
    end
  end

  context 'when constructed with a root' do
    before do
      @mw = described_class.new(root)
    end

    it 'contains one morpheme' do
      expect(@mw.size).to eq 1
    end

    it 'attempting to add a second root raises a RuntimeError' do
      msg = 'MorphWord.add: Cannot add a second root.'
      expect { @mw.add(root2) }.to raise_error(RuntimeError, msg)
    end

    context 'when a suffix is added' do
      before do
        @mw.add(suffix1)
      end

      it 'contains two morphemes' do
        expect(@mw.size).to eq 2
      end

      it 'attempting to add an invalid morpheme raises a RuntimeError' do
        msg = 'MorphWord.add: invalid morpheme type.'
        expect { @mw.add(badmorph) }.to raise_error(RuntimeError, msg)
      end

      it 'each() yields the root followed by the suffix' do
        expect { |probe| @mw.each(&probe) }.to \
          yield_successive_args(root, suffix1)
      end

      it 'each() returns a reference to self' do
        @result = @mw.each(&:to_s)
        expect(@result).to equal @mw
      end

      it 'each_with_index() returns a reference to self' do
        @result = @mw.each_with_index { |_obj, _idx| nil }
        expect(@result).to equal @mw
      end

      it 'returns a string representation of the morphword' do
        expect(@mw.to_s).to eq 'root-suffix1'
      end
    end
  end

  context 'with a duplicate' do
    before do
      @mw = described_class.new(root).add(suffix1)
      @dup = @mw.dup
    end

    it 'contains the same morphemes as the original' do
      expect(@dup).to contain_exactly(root, suffix1)
    end

    context 'when another morpheme is added' do
      before do
        @dup.add(prefix1)
      end

      it 'includes the added morph' do
        expect(@dup).to contain_exactly(prefix1, root, suffix1)
      end

      it 'the original does not include the added morph' do
        expect(@mw).to contain_exactly(root, suffix1)
      end
    end
  end

  context 'when constructed with a non-root' do
    it 'raises a RuntimeError' do
      msg = 'MorphWord.initialize: The first morpheme added must be a root.'
      expect { described_class.new(suffix1) }.to raise_error(RuntimeError, msg)
    end
  end
end

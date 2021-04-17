# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'odl/lexical_entry_generator'
require 'morpheme'

RSpec.describe 'ODL::LexicalEntryGenerator' do
  let(:uf_generator) { double('uf_generator') }
  let(:uf1) { double('uf1') }
  let(:uf2) { double('uf2') }

  context 'generating roots of length 1 numbered from 1' do
    let(:el1) { double('element1') }
    let(:el2) { double('element2') }
    before(:example) do
      allow(uf1).to receive(:each).and_yield(el1)
      allow(uf2).to receive(:each).and_yield(el2)
      allow(el1).to receive(:set_morpheme)
      allow(el2).to receive(:set_morpheme)
      allow(uf_generator).to receive(:underlying_forms).with(1)\
                                                       .and_yield(uf1)\
                                                       .and_yield(uf2)
      @generator = ODL::LexicalEntryGenerator.new(uf_generator)
      @entries = @generator.lexical_entries(1, Morpheme::ROOT, 0)
    end
    it 'generates two entries' do
      expect(@entries.size).to eq 2
    end
    it 'generates entries of type root' do
      expect(@entries.all? { |e| e.type == Morpheme::ROOT }).to be true
    end
    it 'numbers the morphemes' do
      expect(@entries.map { |le| le.morpheme.label }).to eq ['r1', 'r2']
    end
    it 'generates entries with the underlying forms' do
      expect(@entries.map(&:uf)).to eq [uf1, uf2]
    end
  end

  context 'generating suffixes of length 2 numbered from 5' do
    let(:el11) { double('element 11') }
    let(:el12) { double('element 12') }
    let(:el21) { double('element 21') }
    let(:el22) { double('element 22') }
    before(:example) do
      allow(uf1).to receive(:each).and_yield(el11).and_yield(el12)
      allow(uf2).to receive(:each).and_yield(el21).and_yield(el22)
      allow(el11).to receive(:set_morpheme)
      allow(el12).to receive(:set_morpheme)
      allow(el21).to receive(:set_morpheme)
      allow(el22).to receive(:set_morpheme)
      allow(uf_generator).to receive(:underlying_forms).with(2)\
                                                       .and_yield(uf1).and_yield(uf2)
      @generator = ODL::LexicalEntryGenerator.new(uf_generator)
      @entries = @generator.lexical_entries(2, Morpheme::SUFFIX, 5)
    end
    it 'generates two entries' do
      expect(@entries.size).to eq 2
    end
    it 'generates entries of type root' do
      expect(@entries.all? { |e| e.type == Morpheme::SUFFIX }).to be true
    end
    it 'numbers the morphemes' do
      expect(@entries.map { |le| le.morpheme.label }).to eq ['s6', 's7']
    end
    it 'generates entries with the underlying forms' do
      expect(@entries.map(&:uf)).to eq [uf1, uf2]
    end
    it 'associates each uf element with the corresponding morpheme' do
      @entries.each do |le|
        le.uf.each do |e|
          expect(e).to have_received(:set_morpheme)
        end
      end
    end
  end
end

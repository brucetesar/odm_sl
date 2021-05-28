# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'lexical_entry'

RSpec.describe LexicalEntry do
  let(:morph) { double('morph') }
  let(:underform) { double('underlying form') }

  before do
    allow(morph).to receive(:type).and_return(:mytype)
    allow(morph).to receive(:label).and_return(:mylabel)
    @lex_entry = described_class.new(morph, underform)
  end

  it 'returns its morpheme' do
    expect(@lex_entry.morpheme).to eq morph
  end

  it 'returns its underlying form' do
    expect(@lex_entry.uf).to eq underform
  end

  it 'returns its morpheme type' do
    expect(@lex_entry.type).to eq :mytype
  end

  it 'returns its morpheme label' do
    expect(@lex_entry.label).to eq :mylabel
  end

  context 'when a duplicate is made' do
    let(:dup_uf) { double('dup uf') }

    before do
      allow(underform).to receive(:dup).and_return(dup_uf)
      allow(underform).to receive(:==).with(dup_uf).and_return(true)
      @dup_lex_entry = @lex_entry.dup
    end

    it 'the duplicate has the same morpheme object' do
      expect(@dup_lex_entry.morpheme).to equal @lex_entry.morpheme
    end

    it 'the duplicate doe not have the underlying form object' do
      expect(@dup_lex_entry.uf).not_to equal @lex_entry.uf
    end

    it 'the duplicate has a duplicate underlying form' do
      expect(@dup_lex_entry.uf).to eq @lex_entry.uf
    end
  end
end

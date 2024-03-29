# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'grammar'

RSpec.describe Grammar do
  context 'with only the system specified' do
    let(:sys) { double('system') }
    let(:morph) { double('morph') }
    let(:con_list) { [:con1] }

    before do
      allow(sys).to receive(:constraints).and_return(con_list)
      @grammar = described_class.new(sys)
    end

    it 'returns a reference to system' do
      expect(@grammar.system).to eq(sys)
    end

    it 'returns an empty ERC list' do
      expect(@grammar.erc_list).to be_empty
    end

    it 'returns an ERC list with the same constraints' do
      expect(@grammar.erc_list.constraint_list).to eq con_list
    end

    it 'returns an empty lexicon' do
      expect(@grammar.lexicon.size).to eq(0)
    end

    it 'returns the label Grammar' do
      expect(@grammar.label).to eq 'Grammar'
    end

    it 'returns nil when a lexical entry is requested' do
      expect(@grammar.get_uf(morph)).to be_nil
    end

    context 'when duplicated with dup' do
      before do
        @dup = @grammar.dup
      end

      it 'has distinct objects for the ERC list' do
        expect(@grammar.erc_list).not_to equal(@dup.erc_list)
      end

      it 'has distinct objects for lexicon' do
        expect(@grammar.lexicon).not_to equal(@dup.lexicon)
      end
    end

    context 'when duplicated with dup_same_lexicon' do
      before do
        @dup = @grammar.dup_same_lexicon
      end

      it 'has distinct objects for the ERC list' do
        expect(@grammar.erc_list).not_to equal(@dup.erc_list)
      end

      it 'has the same object for lexicon' do
        expect(@grammar.lexicon).to equal(@dup.lexicon)
      end
    end
  end

  context 'when given a system and a lexicon' do
    let(:sys) { double('system') }
    let(:lex) { instance_double(Lexicon) }

    before do
      allow(sys).to receive(:constraints).and_return([])
      allow(lex).to receive(:get_uf).with('the_morph').and_return('the_uf')
      @grammar = described_class.new(sys, lexicon: lex)
    end

    it 'returns the given lexicon' do
      expect(@grammar.lexicon).to eq(lex)
    end

    it 'returns uf "the_uf" for the morpheme "the_morph"' do
      expect(@grammar.get_uf('the_morph')).to eq('the_uf')
    end
  end

  context 'when parse_output is called' do
    let(:erc_list) { double('erc_list') }
    let(:lexicon) { double('lexicon') }
    let(:sys) { double('system') }
    let(:output) { double('output') }
    let(:word) { double('word') }

    before do
      allow(sys).to receive(:constraints).and_return([])
      allow(sys).to receive(:parse_output).with(output, lexicon)\
                                          .and_return(word)
      @grammar =
        described_class.new(sys, erc_list: erc_list, lexicon: lexicon)
      @return_value = @grammar.parse_output(output)
    end

    it 'calls system.parse_output' do
      expect(sys).to have_received(:parse_output)
    end

    it 'returns the full word' do
      expect(@return_value).to eq word
    end
  end
end

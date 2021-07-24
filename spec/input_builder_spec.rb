# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'input_builder'
require 'lexical_entry'
require 'morph_word'

RSpec.describe InputBuilder do
  let(:builder) { described_class.new }

  context 'with a lexicon including r1 /s./ and s4 /S:/' do
    let(:r1) { double('r1') }
    let(:s4) { double('s4') }
    let(:uf_r1_1) { double('uf_r1_1') } # first segment of the UF of r1
    let(:uf_s4_1) { double('uf_s4_1') } # first segment of the UF of s4
    let(:in_r1_1) { double('in_r1_1') } # first segment of the input of r1
    let(:in_s4_1) { double('in_s4_1') } # first segment of the input of s4
    let(:uf_r1) { [uf_r1_1] }
    let(:uf_s4) { [uf_s4_1] }

    before do
      allow(r1).to receive(:label).and_return('r1')
      allow(s4).to receive(:label).and_return('s4')
      allow(uf_r1_1).to receive(:dup).and_return(in_r1_1)
      allow(uf_s4_1).to receive(:dup).and_return(in_s4_1)
      @lex_entry_r1 = instance_double(LexicalEntry, 'lex_entry_r1')
      allow(@lex_entry_r1).to receive(:nil?).and_return(false)
      allow(@lex_entry_r1).to receive(:morpheme).and_return(r1)
      allow(@lex_entry_r1).to receive(:uf).and_return(uf_r1)
      @lex_entry_s4 = instance_double(LexicalEntry, 'lex_entry_s4')
      allow(@lex_entry_s4).to receive(:nil?).and_return(false)
      allow(@lex_entry_s4).to receive(:morpheme).and_return(s4)
      allow(@lex_entry_s4).to receive(:uf).and_return(uf_s4)
      @lexicon = [@lex_entry_r1, @lex_entry_s4]
    end

    context "with morphword ['r1']" do
      before do
        @mw = instance_double(MorphWord, "morphword ['r1']")
        allow(@mw).to receive(:each).and_yield(r1)
      end

      it 'returns input with morphword r1' do
        input = builder.input_from_morphword(@mw, @lexicon)
        expect(input.morphword).to eq(@mw)
      end

      it 'returns input with the UF of r1' do
        input = builder.input_from_morphword(@mw, @lexicon)
        expect(input).to eq([in_r1_1])
      end

      it 'returns input with 1 ui pair' do
        input = builder.input_from_morphword(@mw, @lexicon)
        ui_corr = input.ui_corr
        expect(ui_corr.size).to eq(1)
      end

      it 'returns input with ui pair for r1' do
        input = builder.input_from_morphword(@mw, @lexicon)
        ui_corr = input.ui_corr
        expect(ui_corr.in_corr(uf_r1_1)).to eq in_r1_1
      end
    end

    context "with morphword ['r1', 's4']" do
      before do
        @mw = double
        allow(@mw).to receive(:each).and_yield(r1).and_yield(s4)
      end

      it 'returns input with morphword r1s4' do
        input = builder.input_from_morphword(@mw, @lexicon)
        expect(input.morphword).to eq(@mw)
      end

      it 'returns input with UFs of r1 and s4' do
        input = builder.input_from_morphword(@mw, @lexicon)
        expect(input).to eq([in_r1_1, in_s4_1])
      end

      it 'returns input with 2 ui pairs' do
        input = builder.input_from_morphword(@mw, @lexicon)
        ui_corr = input.ui_corr
        expect(ui_corr.size).to eq(2)
      end

      it 'returns input with ui pair for r1' do
        input = builder.input_from_morphword(@mw, @lexicon)
        ui_corr = input.ui_corr
        expect(ui_corr.in_corr(uf_r1_1)).to eq in_r1_1
      end

      it 'returns input with ui pair for s4' do
        input = builder.input_from_morphword(@mw, @lexicon)
        ui_corr = input.ui_corr
        expect(ui_corr.in_corr(uf_s4_1)).to eq in_s4_1
      end
    end

    it 'raises an exception when the morpheme has no lexical entry' do
      mw = double
      bad_m = double(label: 'x1')
      allow(mw).to receive(:each).and_yield(bad_m)
      expect { builder.input_from_morphword(mw, @lexicon) }.to\
        raise_error(RuntimeError)
    end
  end
end

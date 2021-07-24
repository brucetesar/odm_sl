# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/system'
require 'lexical_entry'
require 'morph_word'

module SL
  RSpec.describe System do
    let(:gen) { double('gen') }
    let(:system) { described_class.new }

    # ********************************
    # Specs for the system constraints
    # ********************************
    context 'when the constraints are retrieved' do
      before do
        @con_list = system.constraints
      end

      it 'has 6 constraints' do
        expect(@con_list.size).to eq(6)
      end

      it 'contains WSP' do
        expect(@con_list.any? { |c| c.name == 'WSP' }).to be true
      end

      it 'contains MainLeft' do
        expect(@con_list.any? { |c| c.name == 'ML' }).to be true
      end

      it 'contains MainRight' do
        expect(@con_list.any? { |c| c.name == 'MR' }).to be true
      end

      it 'contains NoLong' do
        expect(@con_list.any? { |c| c.name == 'NoLong' }).to be true
      end

      it 'contains Ident[stress]' do
        expect(@con_list.any? { |c| c.name == 'IDStress' }).to be true
      end

      it 'contains Ident[length]' do
        expect(@con_list.any? { |c| c.name == 'IDLength' }).to be true
      end
    end

    # ***************************************
    # Specs for #input_from_morphword()
    # ***************************************
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

        it '#input_from_morphword returns input with morphword r1' do
          input = system.input_from_morphword(@mw, @lexicon)
          expect(input.morphword).to eq(@mw)
        end

        it '#input_from_morphword returns input with the UF of r1' do
          input = system.input_from_morphword(@mw, @lexicon)
          expect(input).to eq([in_r1_1])
        end

        it '#input_from_morphword returns input with 1 ui pair' do
          input = system.input_from_morphword(@mw, @lexicon)
          ui_corr = input.ui_corr
          expect(ui_corr.size).to eq(1)
        end

        it '#input_from_morphword returns input with ui pair for r1' do
          input = system.input_from_morphword(@mw, @lexicon)
          ui_corr = input.ui_corr
          expect(ui_corr.in_corr(uf_r1_1)).to eq in_r1_1
        end
      end

      context "with morphword ['r1', 's4']" do
        before do
          @mw = double
          allow(@mw).to receive(:each).and_yield(r1).and_yield(s4)
        end

        it '#input_from_morphword returns input with morphword r1s4' do
          input = system.input_from_morphword(@mw, @lexicon)
          expect(input.morphword).to eq(@mw)
        end

        it '#input_from_morphword returns input with UFs of r1 and s4' do
          input = system.input_from_morphword(@mw, @lexicon)
          expect(input).to eq([in_r1_1, in_s4_1])
        end

        it '#input_from_morphword returns input with 2 ui pairs' do
          input = system.input_from_morphword(@mw, @lexicon)
          ui_corr = input.ui_corr
          expect(ui_corr.size).to eq(2)
        end

        it '#input_from_morphword returns input with ui pair for r1' do
          input = system.input_from_morphword(@mw, @lexicon)
          ui_corr = input.ui_corr
          expect(ui_corr.in_corr(uf_r1_1)).to eq in_r1_1
        end

        it '#input_from_morphword returns input with ui pair for s4' do
          input = system.input_from_morphword(@mw, @lexicon)
          ui_corr = input.ui_corr
          expect(ui_corr.in_corr(uf_s4_1)).to eq in_s4_1
        end
      end

      it 'raises an exception when the morpheme has no lexical entry' do
        mw = double
        bad_m = double(label: 'x1')
        allow(mw).to receive(:each).and_yield(bad_m)
        expect { system.input_from_morphword(mw, @lexicon) }.to\
          raise_error(RuntimeError)
      end
    end

    # ***************************************
    # Specs for #generate_competitions_1r1s()
    # ***************************************

    context 'when generating competitions_1r1s' do
      before do
        @comp_list = system.generate_competitions_1r1s
      end

      it 'generates 16 competitions' do
        expect(@comp_list.size).to eq 16
      end

      it 'generates competitions of 8 candidates each' do
        expect(@comp_list.all? { |c| c.size == 8 }).to be true
      end

      it 'includes a competition for r1s1' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r1-s1' }
        expect(comp).not_to be_nil
      end

      it 'r1s1 has input s.-s.' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r1-s1' }
        expect(comp[0].input.to_s).to eq 's.-s.'
      end

      it 'r2s1 has input s:-s.' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r2-s1' }
        expect(comp[0].input.to_s).to eq 's:-s.'
      end

      it 'r2s3 has input s:-S.' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r2-s3' }
        expect(comp[0].input.to_s).to eq 's:-S.'
      end
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/system'
require 'sl/output_parser'
require 'sl/syllable'
require 'input'
require 'output'
require 'lexical_entry'
require 'lexicon'

module SL
  RSpec.describe OutputParser do
    let(:system) { System.new }
    let(:parser) { described_class.new(system) }

    RSpec.shared_examples 'parsed output' do
      it 'with output == to the starting output' do
        expect(@word.output).to eq(@output)
      end

      it 'with input matching the lexical entries' do
        expect(@word.input).to eq(@input)
      end

      it "with morphword matching the output's morphword" do
        expect(@word.morphword).to eq(@morphword)
      end

      it 'input syl1 has IO correspondent output syl1' do
        expect(@word.io_out_corr(@word.input[0])).to eq(@word.output[0])
      end

      it 'input syl2 has IO correspondent output syl2' do
        expect(@word.io_out_corr(@word.input[1])).to eq(@word.output[1])
      end

      it 'output syl1 has IO correspondent input syl1' do
        expect(@word.io_in_corr(@word.output[0])).to eq(@word.input[0])
      end

      it 'output syl2 has IO correspondent input syl2' do
        expect(@word.io_in_corr(@word.output[1])).to eq(@word.input[1])
      end
    end

    context 'with lexicon including r1 /s./ and s1 /S:/' do
      let(:r1) { double('r1') }
      let(:s1) { double('s1') }

      before do
        allow(r1).to receive(:label).and_return('r1')
        allow(s1).to receive(:label).and_return('s1')
        @in_sylr1 = Syllable.new.set_unstressed.set_short.set_morpheme(r1)
        @lex_entry_r1 = double('lex_entry_r1')
        allow(@lex_entry_r1).to receive(:nil?).and_return(false)
        allow(@lex_entry_r1).to receive(:morpheme).and_return(r1)
        allow(@lex_entry_r1).to receive(:uf).and_return([@in_sylr1])
        @in_syls1 = Syllable.new.set_main_stress.set_long.set_morpheme(s1)
        @lex_entry_s1 = double('lex_entry_s1')
        allow(@lex_entry_s1).to receive(:nil?).and_return(false)
        allow(@lex_entry_s1).to receive(:morpheme).and_return(s1)
        allow(@lex_entry_s1).to receive(:uf).and_return([@in_syls1])
        @lex = [@lex_entry_r1, @lex_entry_s1]
        # distinct objects from the ones in the lexicon
        @input = Input.new << @in_sylr1.dup << @in_syls1.dup
      end

      context 'with parsed output s.S.' do
        before do
          @out_syl1 =
            Syllable.new.set_unstressed.set_short.set_morpheme(r1)
          @out_syl2 =
            Syllable.new.set_main_stress.set_short.set_morpheme(s1)
          @morphword = instance_double(MorphWord)
          allow(@morphword).to receive(:each).and_yield(r1).and_yield(s1)
          @output = Output.new << @out_syl1 << @out_syl2
          @output.morphword = @morphword
          @word = parser.parse_output(@output, @lex)
        end

        include_examples 'parsed output'
      end
    end

    context 'with a lexicon containing only r1 /s./' do
      let(:r1) { double('r1') }
      let(:s1) { double('s1') }

      before do
        allow(r1).to receive(:label).and_return('r1')
        allow(s1).to receive(:label).and_return('s1')
        @in_sylr1 = Syllable.new.set_unstressed.set_short.set_morpheme(r1)
        @lex_entry_r1 = instance_double(LexicalEntry, 'lex_entry_r1')
        allow(@lex_entry_r1).to receive(:nil?).and_return(false)
        allow(@lex_entry_r1).to receive(:morpheme).and_return(r1)
        allow(@lex_entry_r1).to receive(:uf).and_return([@in_sylr1])

        @lex = instance_double(Lexicon, 'lexicon')
        # only r1 is in the lexicon
        allow(@lex).to receive(:any?).and_return(true, false)
        # only r1 is in the lexicon
        allow(@lex).to receive(:find).and_return(@lex_entry_r1, nil)

        @in_syls1 = Syllable.new.set_morpheme(s1)
        @lex_entry_s1 = instance_double(LexicalEntry, 'lex_entry_s1')
        allow(@lex_entry_s1).to receive(:nil?).and_return(false)
        allow(@lex_entry_s1).to receive(:morpheme).and_return(s1)
        allow(@lex_entry_s1).to receive(:uf).and_return([@in_syls1])
        # should only be called *after* the lexical entry would have been added
        allow(@lex).to receive(:find).and_return(@lex_entry_r1, @lex_entry_s1)
        # The input *after* the new lexical entry for s1 is created.
        # Distinct objects from the ones in the lexicon.
        @input = Input.new << @in_sylr1.dup << @in_syls1.dup
      end

      context 'when output s.S. is parsed' do
        before do
          @out_syl1 =
            Syllable.new.set_unstressed.set_short.set_morpheme(r1)
          @out_syl2 =
            Syllable.new.set_main_stress.set_short.set_morpheme(s1)
          @morphword = instance_double(MorphWord)
          allow(@morphword).to receive(:each).and_yield(r1).and_yield(s1)
          @output = Output.new << @out_syl1 << @out_syl2
          @output.morphword = @morphword
          allow(@lex).to receive(:<<)
          @word = parser.parse_output(@output, @lex)
        end

        it 'creates a new lexical entry for s1' do
          expect(@lex).to have_received(:<<).once
        end

        include_examples 'parsed output'

        it "the word's 2nd input syllable is unset for stress" do
          expect(@word.input[1].stress_unset?).to be true
        end

        it "the word's 2nd input syllable is unset for length" do
          expect(@word.input[1].length_unset?).to be true
        end
      end
    end
  end
end

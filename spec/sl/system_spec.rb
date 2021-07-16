# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/system'
require 'lexicon'
require 'lexical_entry'
require 'morph_word'
require 'input'
require 'output'
require 'io_correspondence'
require 'sl/syllable'

RSpec.describe SL::System do
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

  # *************************
  # Specs for #parse_output()
  # *************************

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
      @in_sylr1 = SL::Syllable.new.set_unstressed.set_short.set_morpheme(r1)
      @lex_entry_r1 = double('lex_entry_r1')
      allow(@lex_entry_r1).to receive(:nil?).and_return(false)
      allow(@lex_entry_r1).to receive(:morpheme).and_return(r1)
      allow(@lex_entry_r1).to receive(:uf).and_return([@in_sylr1])
      @in_syls1 = SL::Syllable.new.set_main_stress.set_long.set_morpheme(s1)
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
          SL::Syllable.new.set_unstressed.set_short.set_morpheme(r1)
        @out_syl2 =
          SL::Syllable.new.set_main_stress.set_short.set_morpheme(s1)
        @morphword = instance_double('Morphword')
        allow(@morphword).to receive(:each).and_yield(r1).and_yield(s1)
        @output = Output.new << @out_syl1 << @out_syl2
        @output.morphword = @morphword
        @word = system.parse_output(@output, @lex)
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
      @in_sylr1 = SL::Syllable.new.set_unstressed.set_short.set_morpheme(r1)
      @lex_entry_r1 = instance_double(LexicalEntry, 'lex_entry_r1')
      allow(@lex_entry_r1).to receive(:nil?).and_return(false)
      allow(@lex_entry_r1).to receive(:morpheme).and_return(r1)
      allow(@lex_entry_r1).to receive(:uf).and_return([@in_sylr1])

      @lex = instance_double(Lexicon, 'lexicon')
      # only r1 is in the lexicon
      allow(@lex).to receive(:any?).and_return(true, false)
      # only r1 is in the lexicon
      allow(@lex).to receive(:find).and_return(@lex_entry_r1, nil)

      @in_syls1 = SL::Syllable.new.set_morpheme(s1)
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
          SL::Syllable.new.set_unstressed.set_short.set_morpheme(r1)
        @out_syl2 =
          SL::Syllable.new.set_main_stress.set_short.set_morpheme(s1)
        @morphword = instance_double('Morphword')
        allow(@morphword).to receive(:each).and_yield(r1).and_yield(s1)
        @output = Output.new << @out_syl1 << @out_syl2
        @output.morphword = @morphword
        allow(@lex).to receive(:<<)
        @word = system.parse_output(@output, @lex)
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

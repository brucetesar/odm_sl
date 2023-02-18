# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'pas/gen'
require 'pas/system'
require 'pas/syllable'
require 'input'

module PAS
  RSpec.describe Gen do
    let(:gen) { described_class.new(System.new) }
    let(:morph1) { 'morph1' }
    let(:morph2) { 'morph2' }
    let(:morphword) { 'morphword' }
    let(:syl1) { Syllable.new }
    let(:syl2) { Syllable.new }
    let(:input) { Input.new }

    # A real challenge with using test doubles here is the wide use of
    # #dup methods internally, on classes like Input and Syllable.
    # It requires that mock object creation methods be created and threaded
    # into the initial mock objects, and new stubs must be added to each of the
    # newly created mock objects, *and* duplication of state of duped mock
    # objects must be replicated.
    # Here, the actual classes Input and Syllable are used.

    # ***************************
    # *** 1-Syllable Examples ***
    # ***************************

    RSpec.shared_examples 'PAS 1-syllable competition' do
      it 'generates a competition with 7 constraints' do
        expect(@competition[0].constraint_list.size).to eq(7)
      end

      it 'generates 4 candidates' do
        expect(@competition.size).to eq(4)
      end

      ['s.', 's:', 'S.', 'S:'].each do |out_str|
        context "the candidate with output #{out_str}" do
          let(:word) { @competition.find { |w| w.output.to_s == out_str } }

          it 'is generated' do
            expect(word).not_to be_nil
          end

          it 'has input == to the original input' do
            expect(word.input).to eq(input)
          end

          it 'has the original morphword' do
            expect(word.morphword).to eq(morphword)
          end

          it '1st input syl associated with the 1st morpheme' do
            expect(word.input[0].morpheme).to eq(morph1)
          end

          it '1st output syl associated with the 1st morpheme' do
            expect(word.output[0].morpheme).to eq(morph1)
          end

          it '1st input syl corresponds to 1st output syl' do
            expect(word.io_out_corr(word.input[0])).to eq(word.output[0])
          end

          it '1st output syl corresponds to 1st input syl' do
            expect(word.io_in_corr(word.output[0])).to eq(word.input[0])
          end
        end
      end
    end

    context 'with input /s:/' do
      before do
        syl1.set_unstressed.set_long.set_morpheme(morph1)
        input.morphword = morphword
        input << syl1
        @competition = gen.run(input)
      end

      include_examples 'PAS 1-syllable competition'
    end

    context 'with input /s./' do
      before do
        syl1.set_unstressed.set_short.set_morpheme(morph1)
        input.morphword = morphword
        input << syl1
        @competition = gen.run(input)
      end

      include_examples 'PAS 1-syllable competition'
    end

    # ***************************
    # *** 2-Syllable Examples ***
    # ***************************

    RSpec.shared_examples 'PAS 2-syllable competition' do
      it 'gen generates a competition with 7 constraints' do
        expect(@competition[0].constraint_list.size).to eq(7)
      end

      it 'generates 12 candidates' do
        expect(@competition.size).to eq(12)
      end

      ['S.s.', 'S.s:', 'S:s.', 'S:s:', 's.S.', 's.S:', 's:S.', 's:S:',
       's.s.', 's.s:', 's:s:', 's:s.'].each do |out_str|
        context "the candidate with output #{out_str}" do
          let(:word) { @competition.find { |w| w.output.to_s == out_str } }

          it 'is generated' do
            expect(word).not_to be_nil
          end

          it 'has input == to the original input' do
            expect(word.input).to eq(input)
          end

          it 'has the original morphword' do
            expect(word.morphword).to eq(morphword)
          end

          it '1st input syl associated with the 1st morpheme' do
            expect(word.input[0].morpheme).to eq(morph1)
          end

          it '2nd input syl associated with the 2nd morpheme' do
            expect(word.input[1].morpheme).to eq(morph2)
          end

          it '1st output syl associated with the 1st morpheme' do
            expect(word.output[0].morpheme).to eq(morph1)
          end

          it '2nd output syl associated with the 2nd morpheme' do
            expect(word.output[1].morpheme).to eq(morph2)
          end

          it '1st input syl corresponds to 1st output syl' do
            expect(word.io_out_corr(word.input[0])).to eq(word.output[0])
          end

          it '2nd input syl corresponds to 2nd output syl' do
            expect(word.io_out_corr(word.input[1])).to eq(word.output[1])
          end

          it '1st output syl corresponds to 1st input syl' do
            expect(word.io_in_corr(word.output[0])).to eq(word.input[0])
          end

          it '2nd output syl corresponds to 2nd input syl' do
            expect(word.io_in_corr(word.output[1])).to eq(word.input[1])
          end
        end
      end
    end

    context 'with input /s:S./' do
      before do
        syl1.set_unstressed.set_long.set_morpheme(morph1)
        syl2.set_main_stress.set_short.set_morpheme(morph2)
        input.morphword = morphword
        input << syl1 << syl2
        @competition = gen.run(input)
      end

      include_examples 'PAS 2-syllable competition'
    end

    context 'with input /S.s./' do
      before do
        syl1.set_main_stress.set_short.set_morpheme(morph1)
        syl2.set_unstressed.set_short.set_morpheme(morph2)
        input.morphword = morphword
        input << syl1 << syl2
        @competition = gen.run(input)
      end

      include_examples 'PAS 2-syllable competition'
    end
  end
end

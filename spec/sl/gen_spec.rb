# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/system'
require 'sl/gen'
require 'sl/syllable'
require 'input'

RSpec.describe SL::Gen do
  let(:gen) { described_class.new(SL::System.new) }

  # A real challenge with using test doubles here is the wide use of
  # #dup methods internally, on classes like Input and Syllable.
  # It requires that mock object creation methods be created and threaded
  # into the initial mock objects, and new stubs must be added to each of the
  # newly created mock objects, *and* duplication of state of duped mock
  # objects must be replicated.
  # Here, the actual classes Input and Syllable are used.

  # *** 1-Syllable Examples ***

  RSpec.shared_examples '1-syllable Word' do
    it 'has input == to the original input' do
      expect(@word.input).to eq(@input)
    end

    it 'has morphword r1' do
      expect(@word.morphword).to eq('r1')
    end

    it 'has input syl1 associated with r1' do
      expect(@word.input[0].morpheme).to eq('r1')
    end

    it 'input syl1 has IO correspondent output syl1' do
      expect(@word.io_out_corr(@word.input[0])).to eq(@word.output[0])
    end

    it 'output syl1 has IO correspondent input syl1' do
      expect(@word.io_in_corr(@word.output[0])).to eq(@word.input[0])
    end
  end

  context 'with input /s:/' do
    before do
      @syl = SL::Syllable.new.set_unstressed.set_long.set_morpheme('r1')
      @input = Input.new
      @input.morphword = 'r1'
      @input << @syl
      @competition = gen.run(@input)
    end

    it 'gen generates a competition with 6 constraints' do
      expect(@competition[0].constraint_list.size).to eq(6)
    end

    it 'generates 2 candidates' do
      expect(@competition.size).to eq(2)
    end

    ['S.', 'S:'].each do |out_str|
      context "candidate with output #{out_str}" do
        before do
          @word = @competition.find { |w| w.output.to_s == out_str }
        end

        it "generates candidate with output #{out_str}" do
          expect(@word).not_to be nil
        end

        include_examples '1-syllable Word'
      end
    end
  end

  # *** 2-Syllable Examples ***

  RSpec.shared_examples '2-syllable Word' do
    it 'has input == to the original input' do
      expect(@word.input).to eq(@input)
    end

    it 'has morphword r1s1' do
      expect(@word.morphword).to eq('r1s1')
    end

    it 'has input syl1 associated with r1' do
      expect(@word.input[0].morpheme).to eq('r1')
    end

    it 'has input syl2 associated with s1' do
      expect(@word.input[1].morpheme).to eq('s1')
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

  RSpec.shared_examples '2-syllable outputs' do
    it 'gen generates a competition with 6 constraints' do
      expect(@competition[0].constraint_list.size).to eq(6)
    end

    it 'generates 8 candidates' do
      expect(@competition.size).to eq(8)
    end

    ['S.s.', 'S.s:', 'S:s.', 'S:s:', 's.S.', 's.S:', 's:S.', 's:S:'].each \
    do |out_str|
      context "candidate with output #{out_str}" do
        before { @word = @competition.find { |w| w.output.to_s == out_str } }

        it "generates candidate with output #{out_str}" do
          expect(@word).not_to be nil
        end

        include_examples '2-syllable Word'
      end
    end
  end

  context 'with input /s:S./' do
    before do
      @syl1 = SL::Syllable.new.set_unstressed.set_long.set_morpheme('r1')
      @syl2 = SL::Syllable.new.set_main_stress.set_short.set_morpheme('s1')
      @input = Input.new
      @input.morphword = 'r1s1'
      @input << @syl1 << @syl2
      @competition = gen.run(@input)
    end

    include_examples '2-syllable outputs'
  end
end

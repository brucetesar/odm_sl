# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'lexicon'
require 'lexical_entry'
require 'morpheme'

RSpec.describe Lexicon do
  let(:m1) { double('morpheme1') }
  let(:m2) { double('morpheme2') }
  let(:m3) { double('morpheme3') }
  let(:m1_le) { instance_double(LexicalEntry, 'm1_lexical_entry') }
  let(:m2_le) { instance_double(LexicalEntry, 'm2_lexical_entry') }
  let(:m3_le) { instance_double(LexicalEntry, 'm3_lexical_entry') }
  let(:m1_uf) { double('m1_underlying_form') }
  let(:m2_uf) { double('m2_underlying_form') }
  let(:m3_uf) { double('m3_underlying_form') }

  # Allows the parameter to behave like the lexical entry for morpheme m1.
  def acts_like_m1_le(lex_entry)
    allow(lex_entry).to receive(:morpheme).and_return(m1)
    allow(lex_entry).to receive(:uf).and_return(m1_uf)
    allow(lex_entry).to receive(:type).and_return(Morpheme::ROOT)
    allow(lex_entry).to receive(:to_s).and_return('m1_lexical_entry')
  end

  # Allows the parameter to behave like the lexical entry for morpheme m2.
  def acts_like_m2_le(lex_entry)
    allow(lex_entry).to receive(:morpheme).and_return(m2)
    allow(lex_entry).to receive(:uf).and_return(m2_uf)
    allow(lex_entry).to receive(:type).and_return(Morpheme::SUFFIX)
    allow(lex_entry).to receive(:to_s).and_return('m2_lexical_entry')
  end

  before(:example) do
    acts_like_m1_le(m1_le)
    acts_like_m2_le(m2_le)
    @lexicon = Lexicon.new
  end
  context 'with no lexical entries' do
    it 'returns nil for the uf of m1' do
      expect(@lexicon.get_uf(m1)).to be_nil
    end
    it 'returns nil for the uf of m2' do
      expect(@lexicon.get_uf(m2)).to be_nil
    end
    it 'returns nil for the uf of m3' do
      expect(@lexicon.get_uf(m3)).to be_nil
    end
    it 'returns an empty list of roots' do
      expect(@lexicon.roots).to be_empty
    end
    it 'returns an empty list of suffixes' do
      expect(@lexicon.suffixes).to be_empty
    end
    it 'returns an empty list of prefixes' do
      expect(@lexicon.prefixes).to be_empty
    end
    it 'returns an empty string representation' do
      expect(@lexicon.to_s).to eq ''
    end
  end

  # Shared examples that describe the behavior of a lexicon with morphemes
  # m1 and m2. Can be included in any context that properly defines the
  # variable lexicon (using a let statement) as the object to be tested.
  RSpec.shared_examples 'm1+m2' do
    it 'returns the uf for m1' do
      expect(lexicon.get_uf(m1)).to eq(m1_uf)
    end
    it 'returns the uf for m2' do
      expect(lexicon.get_uf(m2)).to eq(m2_uf)
    end
    it 'returns nil for the uf of m3' do
      expect(lexicon.get_uf(m3)).to be_nil
    end
    it 'returns a root list with the m1 lexical entry' do
      # extracting the morpheme makes the example indifferent to whether
      # it is using m1_le or m1_le_dup
      morphs = lexicon.roots.map(&:morpheme)
      expect(morphs).to contain_exactly(m1)
    end
    it 'returns a suffix list with the m2 lexical entry' do
      morphs = lexicon.suffixes.map(&:morpheme)
      expect(morphs).to contain_exactly(m2)
    end
    it 'returns an empty list of prefixes' do
      expect(lexicon.prefixes).to be_empty
    end
    it 'returns a string rep. with m1 and m2' do
      rep = "m1_lexical_entry\nm2_lexical_entry\n"
      expect(lexicon.to_s).to eq rep
    end
  end

  context 'with entries for m1 and m2 but not m3' do
    before(:each) do
      @lexicon.add(m1_le)
      @lexicon.add(m2_le)
    end
    it_behaves_like 'm1+m2' do
      let(:lexicon) { @lexicon }
    end
    context 'a dup' do
      let(:m1_le_dup) { double('m1_lexical_entry_dup') }
      let(:m2_le_dup) { double('m2_lexical_entry_dup') }
      let(:m3_le_dup) { double('m3_lexical_entry_dup') }
      before(:example) do
        allow(m1_le).to receive(:dup).and_return(m1_le_dup)
        allow(m2_le).to receive(:dup).and_return(m2_le_dup)
        allow(m3_le).to receive(:dup).and_return(m3_le_dup)
        acts_like_m1_le(m1_le_dup)
        acts_like_m2_le(m2_le_dup)
        @lex = @lexicon.dup
      end
      it_behaves_like 'm1+m2' do
        let(:lexicon) { @lex }
      end
      it 'is not the same object as the original' do
        expect(@lex).not_to equal @lexicon
      end
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_word_finder'

RSpec.describe 'OTLearn::ContrastWordFinder' do
  let(:grammar) { double('grammar') }
  let(:matcher) { double('contrast matcher') }
  let(:word_search) { double('word_search') }
  let(:m1) { double('m1') }
  let(:m2) { double('m2') }
  let(:m3) { double('m3') }
  let(:m4) { double('m4') }
  before(:example) do
    @finder = OTLearn::ContrastWordFinder.new(grammar,
                                              contrast_matcher: matcher,
                                              word_search: word_search)
  end

  context 'given several words' do
    let(:m1m2) { double('m1m2') }
    let(:m1m4) { double('m1m4') }
    let(:m3m2) { double('m3m2') }
    let(:m3m4) { double('m3m4') }
    before(:example) do
      allow(m1m2).to receive(:morphword).and_return([m1, m2])
      allow(m1m4).to receive(:morphword).and_return([m1, m4])
      allow(m3m2).to receive(:morphword).and_return([m3, m2])
      allow(m3m4).to receive(:morphword).and_return([m3, m4])
      allow(matcher).to receive(:match?).with([m1, m2], m1, [m1, m4])\
                                        .and_return(false)
      allow(matcher).to receive(:match?).with([m1, m2], m1, [m3, m2])\
                                        .and_return(true)
      allow(matcher).to receive(:match?).with([m1, m2], m1, [m3, m4])\
                                        .and_return(false)
      allow(matcher).to receive(:match?).with([m1, m2], m2, [m1, m4])\
                                        .and_return(true)
      allow(matcher).to receive(:match?).with([m1, m2], m2, [m3, m2])\
                                        .and_return(false)
      allow(matcher).to receive(:match?).with([m1, m2], m2, [m3, m4])\
                                        .and_return(false)
      @others = [m1m4, m3m2, m3m4]
    end
    context 'with alternating environment morphemes' do
      let(:f11) { double('feature11') }
      let(:f21) { double('feature21') }
      let(:f31) { double('feature31') }
      let(:f41) { double('feature41') }
      before(:example) do
        allow(word_search).to receive(:find_unset_features)\
          .with([m1], grammar).and_return([f11])
        allow(word_search).to receive(:find_unset_features)\
          .with([m2], grammar).and_return([f21])
        allow(word_search).to receive(:find_unset_features)\
          .with([m3], grammar).and_return([f31])
        allow(word_search).to receive(:find_unset_features)\
          .with([m4], grammar).and_return([f41])
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f11, [m1m2, m1m4]).and_return(true)
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f21, [m1m2, m3m2]).and_return(true)
        @contrast_words = @finder.contrast_words(m1m2, @others)
      end
      it 'returns the words differing in only one morpheme' do
        expect(@contrast_words).to contain_exactly(m1m4, m3m2)
      end
    end
  end
end

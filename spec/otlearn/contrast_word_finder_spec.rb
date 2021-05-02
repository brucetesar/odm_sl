# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_word_finder'

RSpec.describe 'OTLearn::ContrastWordFinder' do
  let(:grammar) { double('grammar') }
  let(:matcher) { double('contrast matcher') }
  let(:alt_env_finder) { double('alt_env_finder') }
  let(:word_search) { double('word_search') }
  let(:m1) { double('m1') }
  let(:m2) { double('m2') }
  let(:m3) { double('m3') }
  let(:m4) { double('m4') }
  before(:example) do
    @finder = OTLearn::ContrastWordFinder.new(grammar,
                                              contrast_matcher: matcher,
                                              alt_env_finder: alt_env_finder,
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
      allow(matcher).to receive(:match).with([m1, m2], m1, [m1, m4])\
                                       .and_return(nil)
      allow(matcher).to receive(:match).with([m1, m2], m1, [m3, m2])\
                                       .and_return(m3)
      allow(matcher).to receive(:match).with([m1, m2], m1, [m3, m4])\
                                       .and_return(nil)
      allow(matcher).to receive(:match).with([m1, m2], m2, [m1, m4])\
                                       .and_return(m4)
      allow(matcher).to receive(:match).with([m1, m2], m2, [m3, m2])\
                                       .and_return(nil)
      allow(matcher).to receive(:match).with([m1, m2], m2, [m3, m4])\
                                       .and_return(nil)
      @others = [m1m4, m3m2, m3m4]
    end
    context 'with unset alternating environment morphemes' do
      before(:example) do
        # m2 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m2], grammar).and_return([:found_feature])
        # m2 has an unset feature that alternates for m1m2, m3m2
        allow(alt_env_finder).to receive(:find).with(m1m2, m1, [m3m2])\
                                               .and_return([m3m2])
        # m1 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m1], grammar).and_return([:found_feature])
        # m1 has an unset feature that alternates for m1m2, m1m4
        allow(alt_env_finder).to receive(:find).with(m1m2, m2, [m1m4])\
                                               .and_return([m1m4])
        @contrast_words = @finder.contrast_words(m1m2, @others)
      end
      it 'returns the words differing in only one morpheme' do
        expect(@contrast_words).to contain_exactly(m1m4, m3m2)
      end
    end
    context 'with one unset alternating environment morpheme' do
      before(:example) do
        # m2 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m2], grammar).and_return([:found_feature])
        # m2 has an unset feature that alternates for m1m2, m3m2
        allow(alt_env_finder).to receive(:find).with(m1m2, m1, [m3m2])\
                                               .and_return([m3m2])
        # m1 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m1], grammar).and_return([:found_feature])
        # m1 has no unset feature that alternates for m1m2, m1m4
        allow(alt_env_finder).to receive(:find).with(m1m2, m2, [m1m4])\
                                               .and_return([])
        @contrast_words = @finder.contrast_words(m1m2, @others)
      end
      it 'returns the word with the unset contrast morpheme' do
        expect(@contrast_words).to contain_exactly(m3m2)
      end
    end
    context 'with no unset target morph features, one unset contrast morph' do
      before(:example) do
        # m2 has no unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m2], grammar).and_return([])
        # m2 has no unset feature that alternates for m1m2, m3m2
        allow(alt_env_finder).to receive(:find).with(m1m2, m1, [m3m2])\
                                               .and_return([])
        # m1 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m1], grammar).and_return([:found_feature])
        # m1 has an unset feature that alternates for m1m2, m1m4
        allow(alt_env_finder).to receive(:find).with(m1m2, m2, [m1m4])\
                                               .and_return([m1m4])
        # m4 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m4], grammar).and_return([:found_feature])
        @contrast_words = @finder.contrast_words(m1m2, @others)
      end
      it 'returns the word with the unset contrast morpheme' do
        expect(@contrast_words).to contain_exactly(m1m4)
      end
    end
    context 'with no unset target morph, no unset contrast morph' do
      before(:example) do
        # m2 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m2], grammar).and_return([:found_feature])
        # m2 has an unset feature, but m3m2 is ineligible
        allow(alt_env_finder).to receive(:find).with(m1m2, m1, [])\
                                               .and_return([])
        # m1 has no unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m1], grammar).and_return([])
        # m1 has no unset feature that alternates for m1m2, m1m4
        allow(alt_env_finder).to receive(:find).with(m1m2, m2, [m1m4])\
                                               .and_return([])
        # m3 has no unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m3], grammar).and_return([])
        # m4 has an unset feature
        allow(word_search).to receive(:find_unset_features)\
          .with([m4], grammar).and_return([:found_feature])
        @contrast_words = @finder.contrast_words(m1m2, @others)
      end
      # m3m2 blocked b/c neither m1 nor m3 has an unset feature.
      # m1m4 blocked b/c m1 has no unset, thus no unset alternating feature.
      it 'returns no words' do
        expect(@contrast_words).to be_empty
      end
      it 'checked for unset environment features for m1m4' do
        expect(alt_env_finder).to have_received(:find).with(m1m2, m2, [m1m4])
      end
    end
  end
end

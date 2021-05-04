# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/alt_env_finder'

RSpec.describe 'OTLearn::AltEnvFinder' do
  let(:grammar) { double('grammar') }
  let(:m1) { double('m1') }
  let(:m2) { double('m2') }
  let(:m3) { double('m3') }
  let(:m4) { double('m4') }
  let(:m1m2) { double('m1m2') }
  let(:m1m4) { double('m1m4') }
  let(:m3m2) { double('m3m2') }
  let(:m3m4) { double('m3m4') }
  let(:word_search) { double('word_search') }
  before(:example) do
    allow(m1m2).to receive(:morphword).and_return([m1, m2])
    allow(m1m4).to receive(:morphword).and_return([m1, m4])
    allow(m3m2).to receive(:morphword).and_return([m3, m2])
    allow(m3m4).to receive(:morphword).and_return([m3, m4])
    @finder = OTLearn::AltEnvFinder.new(word_search: word_search)
  end

  context 'with all features unset' do
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
    end
    context 'with m2 alternating in m1m2 and m3m2' do
      before(:example) do
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f21, [m1m2, m3m2]).and_return(true)
        others = [m3m2]
        @words = @finder.find(m1m2, m1, others, grammar)
      end
      it 'finds m3m2 for m1m2' do
        expect(@words).to contain_exactly(m3m2)
      end
    end
    context 'with m1 alternating in m1m2 and m1m4' do
      before(:example) do
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f11, [m1m2, m1m4]).and_return(true)
        others = [m1m4]
        @words = @finder.find(m1m2, m2, others, grammar)
      end
      it 'finds m1m4 for m1m2' do
        expect(@words).to contain_exactly(m1m4)
      end
    end
    context 'with m1 not alternating in m1m2 and m1m4' do
      before(:example) do
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f11, [m1m2, m1m4]).and_return(false)
        others = [m1m4]
        @words = @finder.find(m1m2, m2, others, grammar)
      end
      it 'finds no words for m1m2' do
        expect(@words).to be_empty
      end
    end
  end

  context 'with only one unset feature in m1' do
    let(:f11) { double('feature11') }
    let(:f21) { double('feature21') }
    let(:f31) { double('feature31') }
    let(:f41) { double('feature41') }
    before(:example) do
      allow(word_search).to receive(:find_unset_features)\
        .with([m1], grammar).and_return([f11])
      allow(word_search).to receive(:find_unset_features)\
        .with([m2], grammar).and_return([])
      allow(word_search).to receive(:find_unset_features)\
        .with([m3], grammar).and_return([])
      allow(word_search).to receive(:find_unset_features)\
        .with([m4], grammar).and_return([])
    end
    context 'with m2 alternating in m1m2 and m3m2' do
      before(:example) do
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f21, [m1m2, m3m2]).and_return(true)
        others = [m3m2]
        @words = @finder.find(m1m2, m1, others, grammar)
      end
      it 'finds no words for m1m2' do
        expect(@words).to be_empty
      end
    end
    context 'with m1 alternating in m1m2 and m1m4' do
      before(:example) do
        allow(word_search).to receive(:conflicting_output_values?)\
          .with(f11, [m1m2, m1m4]).and_return(true)
        others = [m1m4]
        @words = @finder.find(m1m2, m2, others, grammar)
      end
      it 'finds m1m4 for m1m2' do
        expect(@words).to contain_exactly(m1m4)
      end
    end
  end
end

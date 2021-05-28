# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'hierarchy'

RSpec.shared_examples '3 stratum' do
  it 'has first stratum [c1]' do
    expect(@test_hier[0]).to eq ['c1']
  end

  it 'has second stratum [c2, c3]' do
    expect(@test_hier[1]).to eq %w[c2 c3]
  end

  it 'has third stratum [c4]' do
    expect(@test_hier[2]).to eq ['c4']
  end

  it 'has string representation [c1] [c2 c3] [c4]' do
    expect(@test_hier.to_s).to eq '[c1] [c2 c3] [c4]'
  end
end

RSpec.describe Hierarchy do
  before do
    @hier = described_class.new
    @hier << ['c1'] << %w[c2 c3] << ['c4']
  end

  context 'when [ [c1], [c2, c3], [c4] ]' do
    before do
      @test_hier = @hier
    end

    it_behaves_like '3 stratum'

    context 'when duplicated' do
      before do
        @test_hier = @hier.dup
      end

      it_behaves_like '3 stratum'
    end
  end
end

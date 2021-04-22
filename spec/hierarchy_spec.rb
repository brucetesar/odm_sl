# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'hierarchy'

RSpec.shared_examples '3 stratum' do
  before(:example) do
  end
  it 'has first stratum [c1]' do
    expect(@test_hier[0]).to eq ['c1']
  end
  it 'has second stratum [c2, c3]' do
    expect(@test_hier[1]).to eq ['c2', 'c3']
  end
  it 'has third stratum [c4]' do
    expect(@test_hier[2]).to eq ['c4']
  end
  it 'has string representation [c1] [c2 c3] [c4]' do
    expect(@test_hier.to_s).to eq '[c1] [c2 c3] [c4]'
  end
end

RSpec.describe 'Hierarchy' do
  before(:example) do
    @hier = Hierarchy.new
    @hier << ['c1'] << ['c2', 'c3'] << ['c4']
  end
  context '[ [c1], [c2, c3], [c4] ]' do
    before(:example) do
      @test_hier = @hier
    end
    it_behaves_like '3 stratum'
    context 'duplicate' do
      before(:example) do
        @test_hier = @hier.dup
      end
      it_behaves_like '3 stratum'
    end
  end
end

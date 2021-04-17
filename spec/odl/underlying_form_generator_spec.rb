# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'odl/underlying_form_generator'

RSpec.describe 'ODL::UnderlyingFormGenerator' do
  let(:element_generator) { double('element generator') }
  let(:e1) { double('element 1') }
  let(:e2) { double('element 2') }
  before(:example) do
    allow(element_generator).to receive(:elements).and_yield(e1).and_yield(e2)
    @generator = ODL::UnderlyingFormGenerator.new(element_generator)
  end

  context 'generating UFs of length 0' do
    before(:example) do
      @uflist = @generator.underlying_forms(0)
    end
    it 'generates 1 UF' do
      expect(@uflist.size).to eq 1
    end
    it 'generates a UF of length 0' do
      expect(@uflist.first.size).to eq 0
    end
  end

  context 'generating UFs of negative length' do
    it 'raises a RuntimeError' do
      expect { @generator.underlying_forms(-1) }.to raise_error(RuntimeError)
    end
  end

  context 'generating UFs of length 1' do
    before(:example) do
      @uflist = @generator.underlying_forms(1)
    end
    it 'generates 2 UFs' do
      expect(@uflist.size).to eq 2
    end
    it 'generates UFs of length 1' do
      @uflist.each do |uf|
        expect(uf.size).to eq 1
      end
    end
  end

  context 'generating UFs of length 2' do
    before(:example) do
      @uflist = @generator.underlying_forms(2)
    end
    it 'generates 4 UFs' do
      expect(@uflist.size).to eq 4
    end
    it 'generates UFs of length 2' do
      @uflist.each do |uf|
        expect(uf.size).to eq 2
      end
    end
  end
end

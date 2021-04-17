# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'odl/element_generator'

RSpec.describe 'ODL::ElementGenerator' do
  let(:element_class) { double('element class') }
  before(:example) do
    @generator = ODL::ElementGenerator.new(element_class)
  end

  context 'with an element with one binary feature' do
    let(:start_el) { double('start_el') }
    let(:f1) { double('feature 1') }
    let(:val11) { double('value 11') }
    let(:val12) { double('value 12') }
    let(:dup1) { double('dup el 1') }
    let(:dup2) { double('dup el 2') }
    let(:finst1) { double('feature instance 1') }
    let(:finst2) { double('feature instance 2') }
    before(:example) do
      allow(element_class).to receive(:new).and_return(start_el)
      allow(start_el).to receive(:each_feature).and_yield(f1)
      allow(f1).to receive(:each_value).and_yield(val11).and_yield(val12)
      allow(f1).to receive(:type).and_return(:f1type)
      allow(start_el).to receive(:dup).and_return(dup1, dup2)
      allow(dup1).to receive(:get_feature).with(:f1type).and_return(finst1)
      allow(dup2).to receive(:get_feature).with(:f1type).and_return(finst2)
      allow(finst1).to receive(:value=).with(val11)
      allow(finst2).to receive(:value=).with(val12)
    end
    context 'when called without a block' do
      before(:example) do
        @el_list = @generator.elements
      end
      it 'returns two elements' do
        expect(@el_list).to eq [dup1, dup2]
      end
      it 'the first element has feature value val11' do
        e1f1 = @el_list[0].get_feature(:f1type)
        expect(e1f1).to have_received(:value=).with(val11)
      end
      it 'the second element has feature value val12' do
        e2f1 = @el_list[1].get_feature(:f1type)
        expect(e2f1).to have_received(:value=).with(val12)
      end
    end
    context 'when called with a block' do
      before(:example) do
        @list = []
        @generator.elements do |e|
          @list << e
        end
      end
      it 'the first element has feature value val11' do
        expect(@list).to eq [dup1, dup2]
      end
    end
  end
end

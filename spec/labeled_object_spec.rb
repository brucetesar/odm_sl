# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'labeled_object'

RSpec.describe LabeledObject do
  let(:myobject) { double('myobject') }

  before do
    allow(myobject).to receive(:label)
    allow(myobject).to receive(:base_method).and_return(true)
    allow(myobject).to receive(:to_s)
    @labeled_object = described_class.new(myobject)
  end

  it 'has the empty string as label' do
    expect(@labeled_object.label).to eq ''
  end

  context 'when a label is assigned' do
    before do
      @labeled_object.label = 'a_label'
    end

    it 'returns the assigned label' do
      expect(@labeled_object.label).to eq 'a_label'
    end

    it 'does not send :label to the base object' do
      expect(myobject).not_to have_received(:label)
    end

    it 'does send :base_method to the base object' do
      @labeled_object.base_method
      expect(myobject).to have_received(:base_method)
    end

    it 'calls #to_s on the base object' do
      @labeled_object.to_s
      expect(myobject).to have_received(:to_s)
    end
  end

  context 'when dup is called' do
    let(:dup_base) { double('dup_base') }

    before do
      allow(myobject).to receive(:dup).and_return(dup_base)
      @labeled_object.label = 'a_label'
      @dup = @labeled_object.dup
    end

    it 'the dup has the same label' do
      expect(@dup.label).to eq 'a_label'
    end

    it 'the label is not affected when the dup label is changed' do
      @dup.label = 'different_label'
      expect(@labeled_object.label).to eq 'a_label'
    end

    it 'the dup contains a dup of the base object' do
      expect(@dup.base_obj).to eq dup_base
    end
  end
end

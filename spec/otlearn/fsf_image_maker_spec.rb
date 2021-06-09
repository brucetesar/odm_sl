# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/fsf_image_maker'
require 'word_values_package'
require 'otlearn/fsf_substep'
require 'sheet'
require 'feature'
require 'feature_instance'
require 'feature_value_pair'

RSpec.describe OTLearn::FsfImageMaker do
  let(:fsf_step) { instance_double(OTLearn::FsfSubstep, 'fsf_step') }
  let(:winner) { double('winner') }
  let(:winner_morphword) { 'winner_morphword' }
  let(:winner_input) { 'winner_input' }
  let(:winner_output) { 'winner_output' }
  let(:fv_pair1) { instance_double(FeatureValuePair, 'fv_pair1') }
  let(:feature_instance1) \
    { instance_double(FeatureInstance, 'feature_instance1') }
  let(:morph1) { 'morph1' }
  let(:feature1) { instance_double(Feature, 'feature1') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { instance_double(Sheet, 'sheet') }
  let(:subsheet) { instance_double(Sheet, 'subsheet') }
  let(:packages_subsheet) { instance_double(Sheet, 'packages_subsheet') }

  before do
    allow(winner).to\
      receive(:morphword).and_return(winner_morphword)
    allow(winner).to receive(:input).and_return(winner_input)
    allow(winner).to receive(:output).and_return(winner_output)
    allow(sheet_class).to\
      receive(:new).and_return(sheet, subsheet, packages_subsheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    allow(subsheet).to receive(:[]=)
    allow(packages_subsheet).to receive(:[]=)
    @fsf_image_maker = described_class.new(sheet_class: sheet_class)
  end

  context 'with a step with a newly set feature' do
    let(:package) \
      { instance_double(WordValuesPackage, 'success feature package') }

    before do
      allow(fv_pair1).to \
        receive(:feature_instance).and_return(feature_instance1)
      allow(feature_instance1).to receive(:morpheme).and_return(morph1)
      allow(feature_instance1).to receive(:feature).and_return(feature1)
      allow(feature1).to receive(:type).and_return('feature_type')
      allow(fv_pair1).to receive(:alt_value).and_return('alt_value')
      allow(fsf_step).to receive(:chosen_package).and_return(package)
      allow(fsf_step).to receive(:changed?).and_return(true)
      allow(fsf_step).to receive(:consistent_packages).and_return([package])
      allow(package).to receive(:word).and_return(winner)
      allow(package).to receive(:values).and_return([fv_pair1])
      @fsf_image = @fsf_image_maker.get_image(fsf_step)
    end

    it 'indicates the type of substep' do
      expect(@fsf_image).to\
        have_received(:[]=).with(1, 1, 'Fewest Set Features')
    end

    it 'indicates that FSF changed the grammar' do
      expect(@fsf_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: TRUE')
    end

    it 'appends the chosen package subsheet' do
      expect(@fsf_image).to have_received(:append).with(subsheet)
    end

    it 'indicates the morphword of the chosen winner' do
      expect(subsheet).to\
        have_received(:[]=).with(2, 2, winner_morphword)
    end

    it 'indicates the input of the chosen winner' do
      expect(subsheet).to\
        have_received(:[]=).with(2, 3, winner_input)
    end

    it 'indicates the output of the chosen winner' do
      expect(subsheet).to\
        have_received(:[]=).with(2, 4, winner_output)
    end

    it 'indicates the newly set feature' do
      expect(subsheet).to \
        have_received(:[]=).with(2, 5, morph1)
    end

    it 'appends the consistent packages subsheet' do
      expect(@fsf_image).to have_received(:append).with(packages_subsheet)
    end

    it 'indicates the morphword of the first consistent winner' do
      expect(packages_subsheet).to\
        have_received(:[]=).with(2, 2, winner_morphword)
    end

    it 'indicates the input of the first consistent winner' do
      expect(packages_subsheet).to\
        have_received(:[]=).with(2, 3, winner_input)
    end

    it 'indicates the output of the first consistent winner' do
      expect(packages_subsheet).to\
        have_received(:[]=).with(2, 4, winner_output)
    end
  end

  context 'with a step without a newly set feature' do
    before do
      allow(fsf_step).to receive(:chosen_package).and_return(nil)
      allow(fsf_step).to receive(:changed?).and_return(false)
      allow(fsf_step).to receive(:consistent_packages).and_return([])
      @fsf_image = @fsf_image_maker.get_image(fsf_step)
    end

    it 'indicates the type of substep' do
      expect(@fsf_image).to\
        have_received(:[]=).with(1, 1, 'Fewest Set Features')
    end

    it 'indicates that FSF did not change the grammar' do
      expect(@fsf_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: FALSE')
    end

    it 'does not append a chosen package subsheet' do
      expect(@fsf_image).not_to have_received(:append).with(subsheet)
    end

    it 'does not append a consistent pakages subsheet' do
      expect(@fsf_image).not_to \
        have_received(:append).with(packages_subsheet)
    end
  end
end

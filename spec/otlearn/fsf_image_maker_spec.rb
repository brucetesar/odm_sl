# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/fsf_image_maker'
require 'word_values_package'

RSpec.describe OTLearn::FsfImageMaker do
  let(:fsf_step) { double('fsf_step') }
  let(:failed_winner) { double('failed_winner') }
  let(:failed_winner_morphword) { 'failed_winner_morphword' }
  let(:failed_winner_input) { 'failed_winner_input' }
  let(:failed_winner_output) { 'failed_winner_output' }
  let(:fv_pair1) { double('fv_pair1') }
  let(:feature_instance1) { double('feature_instance1') }
  let(:morph1) { 'morph1' }
  let(:feature1) { double('feature1') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  let(:subsheet) { double('subsheet') }
  let(:cand_subsheet) { double('cand_subsheet') }

  before do
    allow(failed_winner).to\
      receive(:morphword).and_return(failed_winner_morphword)
    allow(failed_winner).to receive(:input).and_return(failed_winner_input)
    allow(failed_winner).to receive(:output).and_return(failed_winner_output)
    allow(sheet_class).to\
      receive(:new).and_return(sheet, subsheet, cand_subsheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    allow(subsheet).to receive(:[]=)
    allow(cand_subsheet).to receive(:[]=)
    @fsf_image_maker = described_class.new(sheet_class: sheet_class)
  end

  context 'with a step with a newly set feature' do
    let(:package) \
      { instance_double(WordValuesPackage, 'success feature package') }
    let(:cand_list) { [package] }

    before do
      allow(fv_pair1).to \
        receive(:feature_instance).and_return(feature_instance1)
      allow(feature_instance1).to receive(:morpheme).and_return(morph1)
      allow(feature_instance1).to receive(:feature).and_return(feature1)
      allow(feature1).to receive(:type).and_return('feature_type')
      allow(fv_pair1).to receive(:alt_value).and_return('alt_value')
      allow(fsf_step).to receive(:failed_winner).and_return(failed_winner)
      allow(fsf_step).to receive(:newly_set_features).and_return([fv_pair1])
      allow(fsf_step).to receive(:changed?).and_return(true)
      allow(fsf_step).to receive(:success_instances).and_return(cand_list)
      allow(package).to receive(:word).and_return(failed_winner)
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

    it 'appends the subsheet' do
      expect(@fsf_image).to have_received(:append).with(subsheet)
    end

    it 'indicates the failed winner morphword on the subsheet' do
      expect(subsheet).to\
        have_received(:[]=).with(2, 2, failed_winner_morphword)
    end

    it 'indicates the input of the failed winner used' do
      expect(subsheet).to\
        have_received(:[]=).with(2, 3, failed_winner_input)
    end

    it 'indicates the output of the failed winner used' do
      expect(subsheet).to\
        have_received(:[]=).with(2, 4, failed_winner_output)
    end

    it 'indicates the newly set feature' do
      expect(subsheet).to \
        have_received(:[]=).with(2, 5, morph1)
    end

    it 'appends the successful features subsheet' do
      expect(@fsf_image).to have_received(:append).with(cand_subsheet)
    end

    it 'indicates the first candidate morphword on the subsheet' do
      expect(cand_subsheet).to\
        have_received(:[]=).with(2, 2, failed_winner_morphword)
    end

    it 'indicates the input of the first candidate morphword' do
      expect(cand_subsheet).to\
        have_received(:[]=).with(2, 3, failed_winner_input)
    end

    it 'indicates the output of the first candidate morphword' do
      expect(cand_subsheet).to\
        have_received(:[]=).with(2, 4, failed_winner_output)
    end
  end

  context 'with a step without a newly set feature' do
    before do
      allow(fsf_step).to receive(:failed_winner).and_return(nil)
      allow(fsf_step).to receive(:newly_set_features).and_return([])
      allow(fsf_step).to receive(:changed?).and_return(false)
      allow(fsf_step).to receive(:success_instances).and_return([])
      @fsf_image = @fsf_image_maker.get_image(fsf_step)
    end

    it 'indicates the type of substep' do
      expect(@fsf_image).to\
        have_received(:[]=).with(1, 1, 'Fewest Set Features')
    end

    it 'indicates the FSF did not change the grammar' do
      expect(@fsf_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: FALSE')
    end

    it 'appends the subsheet' do
      expect(@fsf_image).to have_received(:append).with(subsheet)
    end

    it 'indicates that no failed winner set a feature' do
      expect(subsheet).to\
        have_received(:[]=).with(1, 2, 'No failed winner set a feature.')
    end

    it 'does not indicate the morphword of a failed winner' do
      expect(subsheet).not_to\
        have_received(:[]=).with(1, 3, failed_winner_morphword)
    end

    it 'does not indicate the input of a failed winner' do
      expect(subsheet).not_to\
        have_received(:[]=).with(1, 4, failed_winner_input)
    end

    it 'does not indicate the output of a failed winner' do
      expect(subsheet).not_to\
        have_received(:[]=).with(1, 5, failed_winner_output)
    end

    it 'does not append a successful features subsheet' do
      expect(@fsf_image).not_to have_received(:append).with(cand_subsheet)
    end
  end
end

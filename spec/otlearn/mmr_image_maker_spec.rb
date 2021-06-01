# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/mmr_image_maker'
require 'sheet'

RSpec.describe OTLearn::MmrImageMaker do
  let(:mmr_step) { double('mmr_step') }
  let(:failed_winner) { double('failed_winner') }
  let(:winner1) { double('winner1') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { instance_double(Sheet, 'sheet') }
  let(:subsheet_chosen) { instance_double(Sheet, 'subsheet_chosen') }
  let(:subsheet_all) { instance_double(Sheet, 'subsheet_all') }
  let(:failed_winner_morphword) { 'failed_winner_morphword' }
  let(:failed_winner_input) { 'failed_winner_input' }
  let(:failed_winner_output) { 'failed_winner_output' }
  let(:winner1_morphword) { 'winner1_morphword' }
  let(:winner1_input) { 'winner1_input' }
  let(:winner1_output) { 'winner1_output' }

  before do
    allow(sheet_class).to receive(:new).and_return(sheet, subsheet_chosen,
                                                   subsheet_all)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    allow(subsheet_chosen).to receive(:[]=)
    allow(subsheet_all).to receive(:[]=)
    @mmr_image_maker = described_class.new(sheet_class: sheet_class)
    allow(failed_winner).to\
      receive(:morphword).and_return(failed_winner_morphword)
    allow(failed_winner).to receive(:input).and_return(failed_winner_input)
    allow(failed_winner).to receive(:output).and_return(failed_winner_output)
    allow(winner1).to\
      receive(:morphword).and_return(winner1_morphword)
    allow(winner1).to receive(:input).and_return(winner1_input)
    allow(winner1).to receive(:output).and_return(winner1_output)
  end

  context 'with an MMR step with a failing winner adopted' do
    let(:failed_winner_list) { [winner1, failed_winner] }

    before do
      allow(mmr_step).to receive(:changed?).and_return(true)
      allow(mmr_step).to receive(:failed_winner).and_return(failed_winner)
      allow(mmr_step).to receive(:failed_winner_list)\
        .and_return(failed_winner_list)
      @mmr_image = @mmr_image_maker.get_image(mmr_step)
    end

    it 'indicates the type of substep' do
      expect(@mmr_image).to\
        have_received(:[]=).with(1, 1, 'Max Mismatch Ranking')
    end

    it 'indicates that MMR changed the grammar' do
      expect(@mmr_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: TRUE')
    end

    it 'appends the chosen winner subsheet' do
      expect(@mmr_image).to have_received(:append).with(subsheet_chosen)
    end

    it 'indicates the morphword of the failed winner used' do
      expect(subsheet_chosen).to\
        have_received(:[]=).with(1, 3, failed_winner_morphword)
    end

    it 'indicates the input of the failed winner used' do
      expect(subsheet_chosen).to\
        have_received(:[]=).with(1, 4, failed_winner_input)
    end

    it 'indicates the output of the failed winner used' do
      expect(subsheet_chosen).to\
        have_received(:[]=).with(1, 5, failed_winner_output)
    end

    it 'appends the all winners subsheet' do
      expect(@mmr_image).to have_received(:append).with(subsheet_all)
    end

    it 'adds the heading to the winners subsheet' do
      expect(subsheet_all).to\
        have_received(:[]=).with(1, 2, 'All Failed Winners')
    end

    it 'indicates the morphword of winner1' do
      expect(subsheet_all).to\
        have_received(:[]=).with(2, 3, winner1_morphword)
    end

    it 'indicates the input of winner1' do
      expect(subsheet_all).to\
        have_received(:[]=).with(2, 4, winner1_input)
    end

    it 'indicates the output of winner1' do
      expect(subsheet_all).to\
        have_received(:[]=).with(2, 5, winner1_output)
    end

    it 'indicates the morphword of winner2' do
      expect(subsheet_all).to\
        have_received(:[]=).with(3, 3, failed_winner_morphword)
    end

    it 'indicates the input of winner2' do
      expect(subsheet_all).to\
        have_received(:[]=).with(3, 4, failed_winner_input)
    end

    it 'indicates the output of winner2' do
      expect(subsheet_all).to\
        have_received(:[]=).with(3, 5, failed_winner_output)
    end
  end

  context 'with an MMR step without a newly set feature' do
    let(:failed_winner_list) { [failed_winner] }

    before do
      allow(mmr_step).to receive(:changed?).and_return(false)
      allow(mmr_step).to receive(:failed_winner).and_return(failed_winner)
      allow(mmr_step).to receive(:failed_winner_list)\
        .and_return(failed_winner_list)
      @mmr_image = @mmr_image_maker.get_image(mmr_step)
    end

    it 'indicates the type of substep' do
      expect(@mmr_image).to\
        have_received(:[]=).with(1, 1, 'Max Mismatch Ranking')
    end

    it 'indicates the MMR did not change the grammar' do
      expect(@mmr_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: FALSE')
    end

    it 'appends the chosen winner subsheet' do
      expect(@mmr_image).to have_received(:append).with(subsheet_chosen)
    end

    it 'indicates the morphword of the failed winner used' do
      expect(subsheet_chosen).to\
        have_received(:[]=).with(1, 3, failed_winner_morphword)
    end

    it 'indicates the input of the failed winner used' do
      expect(subsheet_chosen).to\
        have_received(:[]=).with(1, 4, failed_winner_input)
    end

    it 'indicates the output of the failed winner used' do
      expect(subsheet_chosen).to\
        have_received(:[]=).with(1, 5, failed_winner_output)
    end
  end
end

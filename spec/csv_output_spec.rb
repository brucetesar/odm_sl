# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'csv_output'

RSpec.describe CsvOutput do
  let(:page) { double('page image') }
  let(:sheet) { double('sheet') }
  let(:csv) { double('CSV class') }

  before do
    allow(sheet).to receive(:put_range)
    allow(sheet).to receive(:col_count).and_return(1)
    allow(sheet).to receive(:[]=)
  end

  context 'with a sheet with blanks in headers' do
    before do
      allow(sheet).to receive(:[]).and_return(' ')
      @csv_output = described_class.new(page, sheet: sheet, csv_class: csv)
    end

    it 'puts the page image on the sheet' do
      expect(sheet).to have_received(:put_range).with(2, 1, page)
    end

    it 'does not alter the headers' do
      expect(sheet).not_to have_received(:[]=)
    end
  end

  context 'with a sheet with nils in headers' do
    before do
      allow(sheet).to receive(:[]).and_return(nil)
      @csv_output = described_class.new(page, sheet: sheet, csv_class: csv)
    end

    it 'puts the page image on the sheet' do
      expect(sheet).to have_received(:put_range).with(2, 1, page)
    end

    it 'converts the headers to blanks' do
      expect(sheet).to have_received(:[]=).with(1, 1, ' ')
    end
  end
end

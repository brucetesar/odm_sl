# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/comp_list_reader'

RSpec.describe 'OTGeneric::CompListReader' do
  let(:candidate_reader) { double('candidate_reader') }
  context 'Given a header array and an array with two competitors' do
    let(:row1) { double('data row 1') }
    let(:row2) { double('data row 2') }
    let(:cand11) { double('candidate 11') }
    let(:cand12) { double('candidate 12') }
    before(:example) do
      headers = ['', '', 'Con1', 'Con2', 'Con3']
      data = [row1, row2]
      # initialize the test dummy candidates
      allow(candidate_reader).to receive(:constraints=)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row1).and_return(cand11)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row2).and_return(cand12)
      allow(cand11).to receive(:input).and_return('in1')
      allow(cand12).to receive(:input).and_return('in1')
      # construct the comp_list reader
      cl_reader = OTGeneric::CompListReader.new(cand_reader: candidate_reader)
      @comp_list = cl_reader.arrays_to_comp_list(headers, data)
    end
    it 'the candidate reader receives the constraints' do
      expect(candidate_reader).to have_received(:constraints=)
    end
    it 'returns an array with one competition' do
      expect(@comp_list.size).to eq 1
    end

    context 'the competition' do
      before(:example) do
        @comp = @comp_list[0]
      end
      it 'has two candidates' do
        expect(@comp.size).to eq 2
      end
    end
  end

  context 'given a data array with 5 rows over 2 inputs' do
    let(:row1) { double('data row 1') }
    let(:row2) { double('data row 2') }
    let(:row3) { double('data row 3') }
    let(:row4) { double('data row 4') }
    let(:row5) { double('data row 5') }
    let(:cand11) { double('candidate 11') }
    let(:cand12) { double('candidate 12') }
    let(:cand13) { double('candidate 13') }
    let(:cand21) { double('candidate 21') }
    let(:cand22) { double('candidate 22') }
    before(:example) do
      headers = ['Input', 'Output', 'Con1', 'Con2', 'Con3']
      data = [row1, row2, row3, row4, row5]
      # initialize the test dummy candidates
      allow(candidate_reader).to receive(:constraints=)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row1).and_return(cand11)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row2).and_return(cand12)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row3).and_return(cand13)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row4).and_return(cand21)
      allow(candidate_reader).to receive(:convert_array_to_candidate)\
        .with(row5).and_return(cand22)
      allow(cand11).to receive(:input).and_return('in1')
      allow(cand12).to receive(:input).and_return('in1')
      allow(cand13).to receive(:input).and_return('in1')
      allow(cand21).to receive(:input).and_return('in2')
      allow(cand22).to receive(:input).and_return('in2')
      # construct the comp_list reader
      cl_reader = OTGeneric::CompListReader.new(cand_reader: candidate_reader)
      @comp_list = cl_reader.arrays_to_comp_list(headers, data)
    end
    it 'returns an array with 2 competitions' do
      expect(@comp_list.size).to eq 2
    end
    it 'creates a competition for in1 with 3 candidates' do
      expect(@comp_list[0].size).to eq 3
    end
    it 'creates a competition for in2 with 2 candidates' do
      expect(@comp_list[1].size).to eq 2
    end
  end
end
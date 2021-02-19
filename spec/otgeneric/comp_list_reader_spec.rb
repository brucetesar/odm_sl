# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/comp_list_reader'

RSpec.describe 'OTGeneric::CompListReader' do
  context 'Given a header array and an array with two competitors' do
    let(:candidate_reader) { double('candidate_reader') }
    let(:clist) { double('constraint list') }
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
      allow(cand11).to receive(:constraint_list).and_return(clist)
      allow(clist).to receive(:size).and_return(3)
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
      context 'the first candidate' do
        before(:example) do
          @cand = @comp[0]
        end
        it 'has three constraints' do
          expect(@cand.constraint_list.size).to eq 3
        end
      end
    end
  end
end
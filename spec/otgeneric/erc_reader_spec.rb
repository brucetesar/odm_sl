# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/erc_reader'

RSpec.describe OTGeneric::ErcReader do
  context 'with a header array and an array with 2 ERCs' do
    before do
      headers = ['', 'Con1', 'Con2', 'Con3']
      data = [%w[E1 W L W], %w[E2 e W L]]
      erc_reader = described_class.new
      @erc_list = erc_reader.arrays_to_erc_list(headers, data)
    end

    it 'returns an erc list with 3 constraints' do
      expect(@erc_list.constraint_list.size).to eq(3)
    end

    it "returns a constraint list of ['Con1', 'Con2', 'Con3']" do
      con_names = @erc_list.constraint_list.map(&:name)
      expect(con_names).to contain_exactly('Con1', 'Con2', 'Con3')
    end

    it 'returns an erc list with 2 ERCs' do
      expect(@erc_list.size).to eq(2)
    end

    context 'with the first returned ERC' do
      before do
        @erc1 = @erc_list.to_a[0]
      end

      it 'is of class Erc' do
        expect(@erc1).to be_an_instance_of(Erc)
      end

      it 'has label E1' do
        expect(@erc1.label).to eq('E1')
      end

      it 'has Con1 and Con3 as the winner preferrers' do
        winner_names = @erc1.w_cons.map(&:name)
        expect(winner_names).to contain_exactly('Con1', 'Con3')
      end

      it 'has Con2 as the loser preferrer' do
        loser_names = @erc1.l_cons.map(&:name)
        expect(loser_names).to contain_exactly('Con2')
      end
    end

    context 'with the second returned ERC' do
      before do
        @erc2 = @erc_list.to_a[1]
      end

      it 'has label E2' do
        expect(@erc2.label).to eq('E2')
      end

      it 'has Con2 as the winner preferrer' do
        winner_names = @erc2.w_cons.map(&:name)
        expect(winner_names).to contain_exactly('Con2')
      end

      it 'has Con3 as the loser preferrer' do
        loser_names = @erc2.l_cons.map(&:name)
        expect(loser_names).to contain_exactly('Con3')
      end
    end
  end

  context 'with some constraint names prefixed with F:' do
    before do
      headers = ['', 'M:Con1', 'F:Con2', 'Con3']
      data = [%w[E1 W L W], %w[E2 e W L]]
      erc_reader = described_class.new
      @erc_list = erc_reader.arrays_to_erc_list(headers, data)
    end

    it 'returns an erc list with 3 constraints' do
      expect(@erc_list.constraint_list.size).to eq(3)
    end

    it "returns a constraint list of ['M:Con1', 'F:Con2', 'Con3']" do
      con_names = @erc_list.constraint_list.map(&:name)
      expect(con_names).to contain_exactly('M:Con1', 'F:Con2', 'Con3')
    end

    it 'sets the M: constraints to type Markedness' do
      c1 = @erc_list.constraint_list.find { |c| c.name == 'M:Con1' }
      expect(c1).to be_markedness
    end

    it 'sets the F: constraints to type Faithfulness' do
      c2 = @erc_list.constraint_list.find { |c| c.name == 'F:Con2' }
      expect(c2).to be_faithfulness
    end

    it 'sets constraints without a prefix to type Markedness' do
      c3 = @erc_list.constraint_list.find { |c| c.name == 'Con3' }
      expect(c3).to be_markedness
    end
  end
end

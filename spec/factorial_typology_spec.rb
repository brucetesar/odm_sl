# frozen_string_literal: true

# Author: Bruce Tesar

# The class ErcList is mocked by an internal class, rather than a test
# double, so that it can accumulate some values as an array. The class
# MockErcList is defined outside of the RSpec scope.
#
# Several of the entities in the tests do not need any state or behavior,
# they just need to be identifiable. Instead of using full test doubles,
# the tests below use symbols as simple, unique designators for
# objects being passed into and out of objects. This is important for
# the Erc mock objects, because they need to be identifiable in the
# method MockErcList#consistent?, but they won't necessarily be accessible
# at the time the method is defined.

require 'rspec'
require 'factorial_typology'

# A mock class to stand in for ErcList.
class MockErcList < Array
  attr_accessor :label

  def add_all(new_ones)
    concat(new_ones)
  end

  def consistent?
    consistent_cases = [[:erc1], [:erc2], [:erc11], [:erc12],
                        %i[erc11 erc21], %i[erc11 erc22], %i[erc12 erc21]]
    consistent_cases.member?(self)
  end
end

RSpec.describe FactorialTypology do
  let(:hbound_filter) { double('HBound Filter') }
  let(:erc_list_class) { double('erc_list_class') }
  let(:analyzer_class) { double('analyzer_class') }
  let(:viol_analyzer) { double('viol_analyzer') }
  let(:cand1) { double('candidate 1') }
  let(:cand2) { double('candidate 2') }
  let(:out1) { double('output 1') }
  let(:out2) { double('output 2') }
  let(:con_list) { double('constraint list') }

  before do
    allow(cand1).to receive(:constraint_list).and_return(con_list)
    allow(cand2).to receive(:constraint_list).and_return(con_list)
    allow(cand1).to receive(:output).and_return(out1)
    allow(cand2).to receive(:output).and_return(out2)
    allow(analyzer_class).to receive(:new).and_return(viol_analyzer)
  end

  context 'with 1 competition with two non-HB candidates' do
    before do
      allow(erc_list_class).to receive(:new).with(con_list)\
                                            .and_return(MockErcList.new)
      comp1 = [cand1, cand2]
      contenders1 = [cand1, cand2]
      @comp_list = [comp1]
      allow(viol_analyzer).to receive(:ident_viol_candidates?) \
        .and_return(false)
      @contenders_list = [contenders1]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand1, contenders1).and_return([:erc1])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand2, contenders1).and_return([:erc2])
      @factyp = described_class.new(@comp_list,
                                    erc_list_class: erc_list_class,
                                    hbound_filter: hbound_filter,
                                    viol_analyzer_class: analyzer_class)
    end

    it 'provides the original competition list' do
      expect(@factyp.original_comp_list).to eq @comp_list
    end

    it 'provides the contenders list' do
      expect(@factyp.contender_comp_list).to eq @contenders_list
    end

    it 'provides the correct typology' do
      expect(@factyp.ranking_ercs_list).to eq [[:erc1], [:erc2]]
    end

    it 'labels the erc lists' do
      labels = @factyp.ranking_ercs_list.map(&:label)
      expect(labels).to eq %w[L1 L2]
    end

    it 'provides the winners of the languages' do
      base_lists = @factyp.winner_lists.map(&:base_obj)
      expect(base_lists).to eq [[cand1], [cand2]]
    end

    it 'labels the winner lists' do
      labels = @factyp.winner_lists.map(&:label)
      expect(labels).to eq %w[L1 L2]
    end

    it 'provides the learning data of the languages' do
      base_lists = @factyp.learning_data.map(&:base_obj)
      expect(base_lists).to eq [[out1], [out2]]
    end

    it 'labels the learning data' do
      labels = @factyp.learning_data.map(&:label)
      expect(labels).to eq %w[L1 L2]
    end
  end

  context 'with 1 competition with 1 non-HB and 1 HB candidate' do
    let(:mock_erc_list) { MockErcList.new }

    before do
      allow(mock_erc_list).to receive(:consistent?).and_return(false)
      allow(erc_list_class).to receive(:new).with(con_list)\
                                            .and_return(MockErcList.new)
      comp1 = [cand1, cand2]
      contenders1 = [cand2]
      @comp_list = [comp1]
      allow(viol_analyzer).to receive(:ident_viol_candidates?) \
        .and_return(false)
      @contenders_list = [contenders1]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand2, contenders1).and_return([:erc2])
      @factyp = described_class.new(@comp_list,
                                    erc_list_class: erc_list_class,
                                    hbound_filter: hbound_filter,
                                    viol_analyzer_class: analyzer_class)
    end

    it 'provides the original competition list' do
      expect(@factyp.original_comp_list).to eq @comp_list
    end

    it 'provides just one contender' do
      expect(@factyp.contender_comp_list).to eq @contenders_list
    end

    it 'provides a typology with a single language' do
      expect(@factyp.ranking_ercs_list).to eq [[:erc2]]
    end

    it 'provides the winners of the languages' do
      base_lists = @factyp.winner_lists.map(&:base_obj)
      expect(base_lists).to eq [[cand2]]
    end

    it 'labels the winner lists' do
      labels = @factyp.winner_lists.map(&:label)
      expect(labels).to eq %w[L1]
    end

    it 'provides the learning data of the languages' do
      base_lists = @factyp.learning_data.map(&:base_obj)
      expect(base_lists).to eq [[out2]]
    end

    it 'labels the learning data' do
      labels = @factyp.learning_data.map(&:label)
      expect(labels).to eq %w[L1]
    end
  end

  context 'with 2 competitions with one inconsistent combination' do
    let(:cand11) { double('candidate 11') }
    let(:cand12) { double('candidate 12') }
    let(:cand21) { double('candidate 21') }
    let(:cand22) { double('candidate 22') }
    let(:out11) { double('output 11') }
    let(:out12) { double('output 12') }
    let(:out21) { double('output 21') }
    let(:out22) { double('output 22') }

    before do
      allow(cand11).to receive(:constraint_list).and_return(con_list)
      allow(cand12).to receive(:constraint_list).and_return(con_list)
      allow(cand21).to receive(:constraint_list).and_return(con_list)
      allow(cand22).to receive(:constraint_list).and_return(con_list)
      allow(cand11).to receive(:output).and_return(out11)
      allow(cand12).to receive(:output).and_return(out12)
      allow(cand21).to receive(:output).and_return(out21)
      allow(cand22).to receive(:output).and_return(out22)
      allow(erc_list_class).to receive(:new).with(con_list)\
                                            .and_return(MockErcList.new)
      comp1 = [cand11, cand12]
      contenders1 = [cand11, cand12]
      comp2 = [cand21, cand22]
      contenders2 = [cand21, cand22]
      @comp_list = [comp1, comp2]
      allow(viol_analyzer).to receive(:ident_viol_candidates?) \
        .and_return(false)
      @contenders_list = [contenders1, contenders2]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp2).and_return(contenders2)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand11, contenders1).and_return([:erc11])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand12, contenders1).and_return([:erc12])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand21, contenders2).and_return([:erc21])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand22, contenders2).and_return([:erc22])
      @factyp = described_class.new(@comp_list,
                                    erc_list_class: erc_list_class,
                                    hbound_filter: hbound_filter,
                                    viol_analyzer_class: analyzer_class)
    end

    it 'provides the original competition list' do
      expect(@factyp.original_comp_list).to eq @comp_list
    end

    it 'provides the contenders list' do
      expect(@factyp.contender_comp_list).to eq @contenders_list
    end

    it 'provides the correct typology' do
      expect(@factyp.ranking_ercs_list).to eq \
        [%i[erc11 erc21], %i[erc11 erc22], %i[erc12 erc21]]
    end

    it 'provides the winners of the languages' do
      base_lists = @factyp.winner_lists.map(&:base_obj)
      expect(base_lists).to eq [[cand11, cand21], [cand11, cand22],
                                [cand12, cand21]]
    end

    it 'labels the winner lists' do
      labels = @factyp.winner_lists.map(&:label)
      expect(labels).to eq %w[L1 L2 L3]
    end

    it 'provides the learning data of the languages' do
      base_lists = @factyp.learning_data.map(&:base_obj)
      expect(base_lists).to eq [[out11, out21], [out11, out22],
                                [out12, out21]]
    end

    it 'labels the learning data' do
      labels = @factyp.learning_data.map(&:label)
      expect(labels).to eq %w[L1 L2 L3]
    end
  end

  context 'with 1 competition with two identical violation candidates' do
    before do
      allow(erc_list_class).to receive(:new).with(con_list)\
                                            .and_return(MockErcList.new)
      comp1 = [cand1, cand2]
      contenders1 = [cand1, cand2]
      @comp_list = [comp1]
      allow(viol_analyzer).to receive(:ident_viol_candidates?) \
        .and_return(true)
      @contenders_list = [contenders1]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand1, contenders1).and_return([:erc1])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand2, contenders1).and_return([:erc2])
    end

    it 'raises an exception' do
      expect do
        described_class.new(@comp_list, erc_list_class: erc_list_class,
                                        hbound_filter: hbound_filter,
                                        viol_analyzer_class: analyzer_class)
      end.to raise_error(RuntimeError)
    end
  end
end

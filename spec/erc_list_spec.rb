# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'erc'
require 'erc_list'

RSpec.describe ErcList do
  context 'A new ErcList' do
    let(:con_list) { ['C1', 'C2'] }
    before(:example) do
      @erc_list = ErcList.new(con_list)
    end
    it 'is empty' do
      expect(@erc_list.empty?).to be true
    end
    it 'has size 0' do
      expect(@erc_list.size).to eq 0
    end
    it 'returns a list of the constraints' do
      expect(@erc_list.constraint_list).to contain_exactly(*con_list)
    end
    it 'converts to an empty array' do
      expect(@erc_list.to_a).to be_empty
    end
    it 'converts to an empty array via #to_ary' do
      expect(@erc_list.to_ary).to be_empty
    end
    it 'returns an empty label' do
      expect(@erc_list.label).to eq('')
    end
    it 'raises a RuntimeError when an ERC with different constraints is added' do
      erc_diff = instance_double(Erc, 'erc_diff')
      allow(erc_diff).to receive(:constraint_list).and_return(['C3', 'C4'])
      expect { @erc_list.add(erc_diff) }.to raise_exception(RuntimeError)
    end
    it 'responds to find_all() with an empty ErcList' do
      expect(@erc_list.find_all { true }).to be_empty
    end
    it 'responds to find_all() with an ErcList that includes the constraints' do
      found = @erc_list.find_all { true }
      expect(found.constraint_list).to contain_exactly(*con_list)
    end
    it 'responds to reject() with an empty ErcList' do
      expect(@erc_list.reject { true }).to be_empty
    end
    it 'responds to reject() with an ErcList that includes the constraints' do
      found = @erc_list.reject { true }
      expect(found.constraint_list).to contain_exactly(*con_list)
    end
    it 'responds to partition() with two empty ErcLists' do
      true_list, false_list = @erc_list.partition { true }
      expect(true_list).to be_empty
      expect(false_list).to be_empty
    end
    it 'responds to partion() with a truelist that includes the constraints' do
      # ErcList#partition returns two values, we only care about the first.
      true_list, = @erc_list.partition { true }
      expect(true_list.constraint_list).to contain_exactly(*con_list)
    end
    it 'responds to partion() with a falselist that includes the constraints' do
      # ErcList#partition returns two values, we only care about the second.
      _, false_list = @erc_list.partition { true }
      expect(false_list.constraint_list).to contain_exactly(*con_list)
    end
    context 'when the label is set' do
      before do
        @erc_list.label = 'LABEL'
      end
      it 'returns the label' do
        expect(@erc_list.label).to eq('LABEL')
      end
    end
    context 'when duplicated' do
      before(:example) do
        @erc_list_dup = @erc_list.dup
      end
      it 'the duplicate returns the list of constraints' do
        expect(@erc_list_dup.constraint_list).to eq con_list
      end
    end
  end

  context 'An ErcList with one added erc' do
    let(:con_list) { ['C1', 'C2'] }
    let(:erc1) { double('erc1') }
    before(:example) do
      @erc_list = ErcList.new(con_list)
      allow(erc1).to receive(:constraint_list).and_return(con_list)
      allow(erc1).to receive(:test_cond).and_return(true)
      @erc_list.add(erc1)
    end
    it 'is not empty' do
      expect(@erc_list.empty?).not_to be true
    end
    it 'has size 1' do
      expect(@erc_list.size).to eq(1)
    end
    it 'returns the constraints of the erc' do
      expect(@erc_list.constraint_list).to contain_exactly(*con_list)
    end
    it 'returns true when #any? is satisfied by the erc' do
      expect(@erc_list.any?(&:test_cond)).to be true
    end
    it "returns false when #any? isn't satisfied by the erc" do
      expect(@erc_list.any?(&:nil?)).to be false
    end
    it 'returns block-satisfying members for #find_all' do
      found = @erc_list.find_all(&:test_cond)
      expect(found.to_a).to contain_exactly(erc1)
    end
    it 'returns an ErcList for #find_all' do
      found = @erc_list.find_all(&:test_cond)
      expect(found).to be_an_instance_of(ErcList)
    end
    it 'returns block-violating members for #reject' do
      found = @erc_list.reject(&:test_cond)
      expect(found.to_a).to be_empty
    end
    it 'returns an ErcList for #reject' do
      found = @erc_list.reject(&:test_cond)
      expect(found).to be_an_instance_of(ErcList)
    end
    it 'partitions into one satisfying ERC and no other ERCs' do
      true_list, false_list = @erc_list.partition(&:test_cond)
      expect(true_list.to_a).to contain_exactly(erc1)
      expect(false_list.to_a).to be_empty
    end
    it 'partitions into two ErcList objects' do
      true_list, false_list = @erc_list.partition(&:test_cond)
      expect(true_list).to be_an_instance_of(ErcList)
      expect(false_list).to be_an_instance_of(ErcList)
    end
    it 'returns a duplicate with a list independent of the original' do
      dup_list = @erc_list.dup
      erc_new = instance_double(Erc, 'new erc')
      allow(erc_new).to receive(:constraint_list).and_return(con_list)
      dup_list.add(erc_new)
      expect(@erc_list.to_a).to contain_exactly(erc1)
      expect(dup_list.to_a).to contain_exactly(erc1, erc_new)
    end
    it 'converts to an equivalent array via #to_ary' do
      expect(@erc_list.to_ary).to eq [erc1]
    end

    context 'and a second erc with the same constraints is added' do
      let(:erc2) { double('erc2') }
      before(:example) do
        allow(erc2).to receive(:constraint_list).and_return(['C2', 'C1'])
        allow(erc2).to receive(:test_cond).and_return(false)
        @erc_list.add(erc2)
      end
      it 'has size 2' do
        expect(@erc_list.size).to eq(2)
      end
      it 'returns the constraints of the ercs' do
        expect(@erc_list.constraint_list).to contain_exactly('C1', 'C2')
      end
      it 'returns true when #any? is satisfied by one of the ercs' do
        expect(@erc_list.any?(&:test_cond)).to be true
      end
      it "returns false when #any? isn't satisfied by any of the ercs" do
        expect(@erc_list.any?(&:nil?)).to be false
      end
      it 'returns an array with block-satisfying members for #find_all' do
        found = @erc_list.find_all(&:test_cond)
        expect(found.to_a).to contain_exactly(erc1)
      end
      it 'partitions into one satisfying ERC and one other ERC' do
        true_list, false_list = @erc_list.partition(&:test_cond)
        expect(true_list.to_a).to contain_exactly(erc1)
        expect(false_list.to_a).to contain_exactly(erc2)
      end
    end

    context 'and a second erc with different constraints is added' do
      before do
        @erc_diff = instance_double(Erc)
        allow(@erc_diff).to receive(:constraint_list).and_return(['C3', 'C4'])
      end
      it 'raises a RuntimeError' do
        expect { @erc_list.add(@erc_diff) }.to raise_exception(RuntimeError)
      end
    end

    context 'and a second erc with a different number of constraints is added' do
      before do
        @erc_diff = instance_double(Erc)
        allow(@erc_diff).to receive(:constraint_list)\
          .and_return(['C1', 'C2', 'C3'])
      end
      it 'raises a RuntimeError' do
        expect { @erc_list.add(@erc_diff) }.to raise_exception(RuntimeError)
      end
    end
  end

  context 'An empty ErcList, when ERCS are added from a list' do
    let(:con_list) { ['C1', 'C2'] }
    let(:con_list_diff) { ['C1', 'C4'] }
    before(:example) do
      @erc_orig = instance_double(Erc)
      @erc_same = instance_double(Erc)
      @erc_diff = instance_double(Erc)
      @erc_again = instance_double(Erc)
      allow(@erc_orig).to receive(:constraint_list).and_return(con_list)
      allow(@erc_same).to receive(:constraint_list).and_return(con_list)
      allow(@erc_diff).to receive(:constraint_list).and_return(con_list_diff)
      allow(@erc_again).to receive(:constraint_list).and_return(con_list)
      @generic_list = double('generic_list')
    end
    context 'of homo-constraint ercs' do
      before(:example) do
        allow(@generic_list).to receive(:each).and_yield(@erc_orig)
                                              .and_yield(@erc_same)
        @new_erc_list =
          ErcList.new(con_list).add_all(@generic_list)
      end
      it 'contains the same number of ercs' do
        expect(@new_erc_list.size).to eq(2)
      end
      it 'can be further modified independent of the source list' do
        # This test works because any attempt to add an erc to the source
        # list will fail: test double @generic_list does not accept #add,
        # nor any other method apart from #each.
        @new_erc_list.add(@erc_again)
        expect(@new_erc_list.to_a).to contain_exactly(@erc_again, @erc_orig,
                                                      @erc_same)
      end
    end
    context 'of hetero-constraint ercs' do
      before(:example) do
        allow(@generic_list).to receive(:each).and_yield(@erc_orig)
                                              .and_yield(@erc_diff)
      end
      it 'raises a RuntimeError' do
        expect\
          do
            ErcList.new(con_list).add_all(@generic_list)
          end.to raise_error(RuntimeError)
      end
    end
  end

  # Testing #consistent?

  context 'with no ERCs added' do
    let(:con_list) { ['C1'] }
    before(:example) do
      @erc_list = ErcList.new(con_list)
    end
    it 'responds that it is consistent' do
      expect(@erc_list.consistent?).to be true
    end
  end

  context 'with one consistent ERC added' do
    let(:con_list) { ['C1', 'C2'] }
    before(:example) do
      @erc_consistent = instance_double(Erc)
      allow(@erc_consistent).to receive(:constraint_list)\
        .and_return(con_list)
      @rcd_runner = double('RCD runner')
      rcd_result = instance_double(Rcd)
      allow(rcd_result).to receive(:consistent?).and_return(true)
      @erc_list =
        ErcList.new(con_list, rcd_runner: @rcd_runner)\
               .add(@erc_consistent)
      allow(@rcd_runner).to receive(:run_rcd).with(@erc_list)\
                                             .and_return(rcd_result)
    end
    it 'responds that is is consistent' do
      expect(@erc_list.consistent?).to be true
    end
  end

  context 'with one inconsistent ERC added' do
    let(:con_list) { ['C1', 'C2'] }
    before(:example) do
      @erc_consistent = instance_double(Erc)
      allow(@erc_consistent).to receive(:constraint_list)\
        .and_return(con_list)
      @rcd_runner = double('RCD runner')
      rcd_result = instance_double(Rcd)
      allow(rcd_result).to receive(:consistent?).and_return(false)
      @erc_list =
        ErcList.new(con_list, rcd_runner: @rcd_runner)\
               .add(@erc_consistent)
      allow(@rcd_runner).to receive(:run_rcd).with(@erc_list)\
                                             .and_return(rcd_result)
    end
    it 'responds that it is not consistent' do
      expect(@erc_list.consistent?).to be false
    end
  end
end

RSpec.describe 'ErcList.new_from_competition' do
  # A helper method for setting up winner-loser pair doubles.
  def set_up_wlpair_double(winner, loser, pair, wlpair_class, clist)
    allow(wlpair_class).to receive(:new).with(winner, loser) \
                                        .and_return(pair)
    allow(pair).to receive(:winner).and_return(winner)
    allow(pair).to receive(:loser).and_return(loser)
    allow(pair).to receive(:constraint_list).and_return(clist)
    allow(pair).to receive(:all?).and_return(2)
  end

  let(:wlpair_class) { double('wlpair_class') }
  let(:winner) { double('winner') }
  let(:con_list) { double('constraint list') }
  before(:example) do
    allow(con_list).to receive(:size).and_return(2)
    allow(con_list).to receive(:empty?).and_return(false)
    allow(con_list).to receive(:all?).and_return(true)
    allow(winner).to receive(:constraint_list).and_return(con_list)
  end
  context 'given a competition of size 2' do
    let(:loser1) { double('loser1') }
    let(:pair1) { double('wlpair1') }
    before(:example) do
      competition = [winner, loser1]
      set_up_wlpair_double(winner, loser1, pair1, wlpair_class, con_list)
      @erc_list = ErcList.new_from_competition(winner, competition,
                                               wlpair_class: wlpair_class)
    end
    it 'returns a list of 1 erc' do
      expect(@erc_list.size).to eq 1
    end
    it 'returns an erc with the winner' do
      expect(@erc_list.any? { |erc| erc.winner != winner }).to be false
    end
    it 'returns an erc with the loser' do
      expect(@erc_list.any? { |erc| erc.loser == loser1 }).to be true
    end
  end

  context 'given an empty competition' do
    before(:example) do
      competition = []
      @erc_list = ErcList.new_from_competition(winner, competition,
                                               wlpair_class: wlpair_class)
    end
    it 'returns an empty erc list' do
      expect(@erc_list.empty?).to be(true)
    end
  end
  context 'given a competition with only the winner' do
    before(:example) do
      competition = [winner]
      @erc_list = ErcList.new_from_competition(winner, competition,
                                               wlpair_class: wlpair_class)
    end
    it 'returns an empty erc list' do
      expect(@erc_list.empty?).to be(true)
    end
  end
  context 'given a competition of size 3' do
    let(:loser1) { double('loser1') }
    let(:pair1) { double('wlpair1') }
    let(:loser2) { double('loser2') }
    let(:pair2) { double('wlpair2') }
    before(:example) do
      competition = [loser1, winner, loser2]
      set_up_wlpair_double(winner, loser1, pair1, wlpair_class, con_list)
      set_up_wlpair_double(winner, loser2, pair2, wlpair_class, con_list)
      @erc_list = ErcList.new_from_competition(winner, competition,
                                               wlpair_class: wlpair_class)
    end
    it 'returns a list of 2 ercs' do
      expect(@erc_list.size).to eq 2
    end
    it 'returns all ercs with the winner' do
      expect(@erc_list.any? { |erc| erc.winner != winner }).to be false
    end
    it 'returns an erc with the first loser' do
      expect(@erc_list.any? { |erc| erc.loser == loser1 }).to be true
    end
    it 'returns an erc with the second loser' do
      expect(@erc_list.any? { |erc| erc.loser == loser2 }).to be true
    end
  end
end

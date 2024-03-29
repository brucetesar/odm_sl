# frozen_string_literal: true

# Author: Bruce Tesar

require 'win_lose_pair'

RSpec.describe WinLosePair do
  before do
    @constraint_list = %w[C1 C2]
    @winner = double('Winner')
    allow(@winner).to receive(:input).and_return('input')
    allow(@winner).to receive(:output).and_return('win-output')
    allow(@winner).to receive(:label).and_return('win-label')
    allow(@winner).to receive(:constraint_list).and_return(@constraint_list)
    allow(@winner).to receive(:get_viols).with('C1').and_return(0)
    allow(@winner).to receive(:get_viols).with('C2').and_return(3)
    @loser = double('Loser')
    allow(@loser).to receive(:input).and_return('input')
    allow(@loser).to receive(:output).and_return('lose-output')
    allow(@loser).to receive(:label).and_return('lose-label')
    allow(@loser).to receive(:get_viols).with('C1').and_return(1)
    allow(@loser).to receive(:get_viols).with('C2').and_return(2)
    @win_lose_pair = described_class.new(@winner, @loser)
  end

  it 'returns the winner' do
    expect(@win_lose_pair.winner).to eq @winner
  end

  it 'returns the loser' do
    expect(@win_lose_pair.loser).to eq @loser
  end

  it 'indicates that C1 prefers the winner' do
    expect(@win_lose_pair.w?('C1')).to be true
  end

  it "indicates that C1 doesn't prefer the loser" do
    expect(@win_lose_pair.l?('C1')).not_to be true
  end

  it 'indicates that C1 has a preference' do
    expect(@win_lose_pair.e?('C1')).not_to be true
  end

  it "indicates that C2 doesn't prefer the winner" do
    expect(@win_lose_pair.w?('C2')).not_to be true
  end

  it 'indicates that C2 prefers the loser' do
    expect(@win_lose_pair.l?('C2')).to be true
  end

  it 'indicates that C2 has a preference' do
    expect(@win_lose_pair.e?('C2')).not_to be true
  end

  it 'does not respond to the preference-setting methods of Erc' do
    expect(@win_lose_pair).not_to respond_to(:set_w, :set_l, :set_e)
  end

  context 'when to_s is called' do
    before do
      @str_rep = @win_lose_pair.to_s
    end

    it 'includes the input' do
      expect(/input/ =~ @str_rep).not_to be_nil
    end

    it 'includes the winner output' do
      expect(/win-output/ =~ @str_rep).not_to be_nil
    end

    it 'includes the loser output' do
      expect(/lose-output/ =~ @str_rep).not_to be_nil
    end

    it 'includes the constraint preferences' do
      expect(/C1:W C2:L/ =~ @str_rep).not_to be_nil
    end
  end

  context 'with mis-matching inputs' do
    before do
      @constraint_list = %w[C1 C2]
      @winner = double('Winner')
      allow(@winner).to receive(:input).and_return('one-input')
      allow(@winner).to receive(:label).and_return('win-label')
      allow(@winner).to receive(:constraint_list).and_return(@constraint_list)
      allow(@winner).to receive(:get_viols).with('C1').and_return(0)
      allow(@winner).to receive(:get_viols).with('C2').and_return(3)
      @loser = double('Loser')
      allow(@loser).to receive(:input).and_return('other-input')
      allow(@loser).to receive(:label).and_return('lose-label')
      allow(@loser).to receive(:get_viols).with('C1').and_return(1)
      allow(@loser).to receive(:get_viols).with('C2').and_return(2)
    end

    it 'raises a RuntimeError' do
      expect { described_class.new(@winner, @loser) }.to \
        raise_error(RuntimeError,
                    'The winner and loser do not have the same input.')
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'comparer_factory'

RSpec.describe 'ComparerFactory' do
  before(:example) do
    @factory = ComparerFactory.new
  end

  context 'set for CTie with a faith-low bias' do
    before(:example) do
      @factory.faith_low
      @factory.ctie
      @comparer = @factory.build
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
    it 'returns an rcd_runner' do
      expect(@factory.rcd_runner).to respond_to(:run_rcd)
    end
  end
  context 'set for Pool with a mark-low bias' do
    before(:example) do
      @factory.mark_low
      @factory.pool
      @comparer = @factory.build
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
    it 'returns an rcd_runner' do
      expect(@factory.rcd_runner).to respond_to(:run_rcd)
    end
  end
  context 'set for Consistent' do
    before(:example) do
      @factory.consistent
      @comparer = @factory.build
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
    it 'with no ranking bias rcd_runner raises an exception' do
      expect { @factory.rcd_runner }.to raise_error(RuntimeError)
    end
    context 'and then a ranking bias is set' do
      before(:example) do
        @factory.all_high
      end
      it 'returns an rcd_runner' do
        expect(@factory.rcd_runner).to respond_to(:run_rcd)
      end
    end
  end
  context 'no compare type is set' do
    it 'rcd_runner raises an exception' do
      expect { @factory.rcd_runner }.to raise_error(RuntimeError)
    end
    it 'build raises an exception' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
  context 'set for CTie but no bias type is set' do
    before(:example) do
      @factory.ctie
    end
    it 'raises an exception' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
  context 'set for Pool but no bias type is set' do
    before(:example) do
      @factory.pool
    end
    it 'raises an exception' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
  context 'with Pool and faith_low set on the same line' do
    before(:example) do
      @factory.pool.faith_low
      @comparer = @factory.build
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
    it 'returns an rcd_runner' do
      expect(@factory.rcd_runner).to respond_to(:run_rcd)
    end
  end
  context 'with CTie and mark_low set on the same line' do
    before(:example) do
      @factory.mark_low.ctie
      @comparer = @factory.build
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
    it 'returns an rcd_runner' do
      expect(@factory.rcd_runner).to respond_to(:run_rcd)
    end
  end
  context 'with consistent and all_high set on the same line' do
    before(:example) do
      @factory.consistent.all_high
      @comparer = @factory.build
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
    it 'returns an rcd_runner' do
      expect(@factory.rcd_runner).to respond_to(:run_rcd)
    end
  end
end

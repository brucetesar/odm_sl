# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'comparer_factory'

RSpec.describe ComparerFactory do
  before do
    @factory = described_class.new
  end

  context 'when set for CTie with a faith-low bias' do
    before do
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

  context 'when set for Pool with a mark-low bias' do
    before do
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

  context 'when set for Consistent' do
    before do
      @factory.consistent
      @comparer = @factory.build
    end

    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end

    it 'with no ranking bias rcd_runner raises an exception' do
      expect { @factory.rcd_runner }.to raise_error(RuntimeError)
    end

    context 'when a ranking bias is set' do
      before do
        @factory.all_high
      end

      it 'returns an rcd_runner' do
        expect(@factory.rcd_runner).to respond_to(:run_rcd)
      end
    end
  end

  context 'when no compare type is set' do
    it 'rcd_runner raises an exception' do
      expect { @factory.rcd_runner }.to raise_error(RuntimeError)
    end

    it 'build raises an exception' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end

  context 'when set for CTie but no bias type is set' do
    before do
      @factory.ctie
    end

    it 'raises an exception' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end

  context 'when set for Pool but no bias type is set' do
    before do
      @factory.pool
    end

    it 'raises an exception' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end

  context 'with Pool and faith_low set on the same line' do
    before do
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
    before do
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
    before do
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

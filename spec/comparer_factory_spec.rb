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
      @comparer = @factory.create_comparer
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
  end
  context 'set for Pool with a mark-low bias' do
    before(:example) do
      @factory.mark_low
      @factory.pool
      @comparer = @factory.create_comparer
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
  end
  context 'set for Consistent' do
    before(:example) do
      @factory.consistent
      @comparer = @factory.create_comparer
    end
    it 'returns a comparer' do
      expect(@comparer).to respond_to(:more_harmonic)
    end
  end
  context 'no compare type is set' do
    it 'raises an exception' do
      expect { @factory.create_comparer }.to raise_error(RuntimeError)
    end
  end
  context 'set for CTie but no bias type is set' do
    before(:example) do
      @factory.ctie
    end
    it 'raises an exception' do
      expect { @factory.create_comparer }.to raise_error(RuntimeError)
    end
  end
  context 'set for Pool but no bias type is set' do
    before(:example) do
      @factory.pool
    end
    it 'raises an exception' do
      expect { @factory.create_comparer }.to raise_error(RuntimeError)
    end
  end
end

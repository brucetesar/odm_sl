# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'multi_stress/system'
require 'sl/syllable'

module MultiStress
  RSpec.describe System do
    let(:system) { described_class.new }

    it 'provides the correspondence element class' do
      expect(system.corr_element_class).to eq SL::Syllable
    end

    # ********************************
    # Specs for the system constraints
    # ********************************
    context 'when the constraints are retrieved' do
      before do
        @con_list = system.constraints
      end

      it 'has 8 constraints' do
        expect(@con_list.size).to eq(8)
      end

      it 'contains WSP' do
        expect(@con_list.any? { |c| c.name == 'WSP' }).to be true
      end

      it 'contains StressLeft' do
        expect(@con_list.any? { |c| c.name == 'SL' }).to be true
      end

      it 'contains StressRight' do
        expect(@con_list.any? { |c| c.name == 'SR' }).to be true
      end

      it 'contains NoLong' do
        expect(@con_list.any? { |c| c.name == 'NoLong' }).to be true
      end

      it 'contains Ident[stress]' do
        expect(@con_list.any? { |c| c.name == 'IDStress' }).to be true
      end

      it 'contains Ident[length]' do
        expect(@con_list.any? { |c| c.name == 'IDLength' }).to be true
      end

      it 'contains Culm' do
        expect(@con_list.any? { |c| c.name == 'Culm' }).to be true
      end

      it 'contains Clash' do
        expect(@con_list.any? { |c| c.name == 'Clash' }).to be true
      end
    end
  end
end

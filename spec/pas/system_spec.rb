# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'pas/system'
require 'sl/syllable'

module PAS
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

      it 'has 7 constraints' do
        expect(@con_list.size).to eq(7)
      end

      it 'contains WSP' do
        expect(@con_list.any? { |c| c.name == 'WSP' }).to be true
      end

      it 'contains MainLeft' do
        expect(@con_list.any? { |c| c.name == 'ML' }).to be true
      end

      it 'contains MainRight' do
        expect(@con_list.any? { |c| c.name == 'MR' }).to be true
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
    end
  end
end

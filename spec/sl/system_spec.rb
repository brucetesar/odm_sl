# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/system'
require 'sl/syllable'

module SL
  RSpec.describe System do
    let(:gen) { double('gen') }
    let(:system) { described_class.new }

    it 'provides the correspondence element class' do
      expect(system.corr_element_class).to eq Syllable
    end

    # ********************************
    # Specs for the system constraints
    # ********************************
    context 'when the constraints are retrieved' do
      before do
        @con_list = system.constraints
      end

      it 'has 6 constraints' do
        expect(@con_list.size).to eq(6)
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
    end

    # ***************************************
    # Specs for #generate_competitions_1r1s()
    # ***************************************

    context 'when generating competitions_1r1s' do
      before do
        @comp_list = system.generate_competitions_1r1s
      end

      it 'generates 16 competitions' do
        expect(@comp_list.size).to eq 16
      end

      it 'generates competitions of 8 candidates each' do
        expect(@comp_list.all? { |c| c.size == 8 }).to be true
      end

      it 'includes a competition for r1s1' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r1-s1' }
        expect(comp).not_to be_nil
      end

      it 'r1s1 has input s.-s.' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r1-s1' }
        expect(comp[0].input.to_s).to eq 's.-s.'
      end

      it 'r2s1 has input s:-s.' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r2-s1' }
        expect(comp[0].input.to_s).to eq 's:-s.'
      end

      it 'r2s3 has input s:-S.' do
        comp = @comp_list.find { |c| c[0].morphword.to_s == 'r2-s3' }
        expect(comp[0].input.to_s).to eq 's:-S.'
      end
    end
  end
end

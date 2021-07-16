# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/system'
require 'sl/syllable'
require 'odl/element_generator'
require 'odl/underlying_form_generator'
require 'odl/lexical_entry_generator'
require 'odl/competition_generator'
require 'odl/stress_length_data_generator'

RSpec.describe 'generating competitions for 1r1s', :integration do
  let(:system) { SL::System.new }

  before do
    element_generator = ODL::ElementGenerator.new(SL::Syllable)
    uf_generator = ODL::UnderlyingFormGenerator.new(element_generator)
    lexentry_generator = ODL::LexicalEntryGenerator.new(uf_generator)
    comp_generator = ODL::CompetitionGenerator.new(system)
    data_generator = ODL::StressLengthDataGenerator.new(lexentry_generator,
                                                        comp_generator)
    @comp_list = data_generator.generate_competitions_1r1s
  end

  it 'generates 16 competitions' do
    expect(@comp_list.size).to eq 16
  end

  it 'generates competitions of 8 candidates each' do
    expect(@comp_list.all? { |c| c.size == 8 }).to be true
  end

  it 'includes a competition for r1s1' do
    comp_r1s1 = @comp_list.find { |c| c[0].morphword.to_s == 'r1-s1' }
    expect(comp_r1s1).not_to be_nil
  end

  it 'r1s1 has input s.-s.' do
    comp_r1s1 = @comp_list.find { |c| c[0].morphword.to_s == 'r1-s1' }
    expect(comp_r1s1[0].input.to_s).to eq 's.-s.'
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

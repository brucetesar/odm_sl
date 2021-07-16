# frozen_string_literal: true

# Author: Bruce Tesar

# Acceptance tests for typology generation, using the system SL.
# The factorial typology for SL using word forms 1r1s, where all words
# consist of a 1-syllable root and a 1-syllable suffix, is generated.
# The outputs of each generated language are then compared to the
# corresponding set of outputs in a fixture file.

require_relative '../../lib/odl/resolver'
require 'sl/system'
require 'factorial_typology'
require 'sync_enum'
require 'psych'
require 'labeled_object'

RSpec.describe FactorialTypology, :acceptance do
  context 'when generating the typology for SL 1r1s' do
    # Generate the typology data
    system = SL::System.new
    competition_list = system.generate_competitions_1r1s
    ft_result = described_class.new(competition_list)
    generated_data = ft_result.learning_data
    # Retrieve the fixture data
    fixture_file = File.join(ODL::SPEC_DIR, 'fixtures', 'sl',
                             'outputs_typology_1r1s.yml')
    fixture_data = Psych.load_file(fixture_file)

    it 'generates the correct number of languages for SL 1r1s' do
      expect(generated_data.size).to eq fixture_data.size
    end

    iter = SyncEnum.new(generated_data.to_enum, fixture_data.to_enum)
    loop do
      gen_lang, fix_lang = iter.next
      it "generates a language with the label #{fix_lang.label}" do
        expect(gen_lang.label).to eq fix_lang.label
      end

      # Attempting to directly compare gen_lang and fix_lang with eq
      # crashes RSpec. Something to do with the role played by the
      # LabeledObject decorator class. Converting them to arrays seems
      # to solve the problem.
      it "generates the outputs for language #{fix_lang.label}" do
        expect(gen_lang.to_a).to eq fix_lang.to_a
      end
    end
  end
end

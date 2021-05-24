# frozen_string_literal: true

# Author: Bruce Tesar
#
# Generates the entire topology for the SL system with
# monosyllabic morphemes and root+suffix words (1r1s).

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

require 'sl/system'
require 'factorial_typology'
require 'otlearn/language_learning_runner'
require 'psych'

# Generate the language typology data:
# a list of sets of language data, one for each language in
# the typology of the SL system, with each root and each suffix
# consisting of a single syllable (1r1s).
system = SL::System.instance
competition_list = system.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)
lang_list = ft_result.factorial_typology

# Set the SL data directory.
data_dir = File.expand_path('sl', ODL::DATA_DIR)
# If the directory doesn't already exist, create it.
Dir.mkdir(data_dir) unless Dir.exist?(data_dir)

# Write the data for each language of the typology to a data file.
# Uses Psych to write an object to file in YAML format.
outputs_list = lang_list.map do |lang|
  [lang.label, OTLearn::LanguageLearningRunner.wlp_to_learning_data(lang)]
end
yml_file = File.join(data_dir, 'outputs_typology_1r1s.yml')
File.open(yml_file, 'w') do |f|
  Psych.dump(outputs_list, f)
end

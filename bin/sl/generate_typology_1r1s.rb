# frozen_string_literal: true

# Author: Bruce Tesar

# Generates the entire topology for the SL system with monosyllabic
# morphemes and root+suffix words (1r1s).

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

require 'sl/system'
require 'factorial_typology'

system = SL::System.new

# Add a system-specific subdirectory in the data directory.
data_dir = File.expand_path('sl', ODL::DATA_DIR)

# Create the competitions, and generate the typology.
competition_list = system.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)

# Write the typological results to report files.
ft_result.write_to_files(data_dir, '1r1s')

yml_file = File.join(data_dir, 'sl_system.yml')
File.open(yml_file, 'w') do |f|
  f.write(Psych.dump(system))
end

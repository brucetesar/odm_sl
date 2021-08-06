# frozen_string_literal: true

# Author: Bruce Tesar

# Generates the entire topology for the MultiStress system with monosyllabic
# morphemes and root+suffix words (1r1s).

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

require 'multi_stress/system'
require 'factorial_typology'

system = MultiStress::System.new

# Add a system-specific subdirectory in the data directory.
data_dir = File.expand_path('multi_stress', ODL::DATA_DIR)

# Create the competitions, and generate the typology.
competition_list = system.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)

# Write the typological results to report files.
ft_result.write_to_files(data_dir, '1r1s')

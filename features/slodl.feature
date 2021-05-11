Feature: slodl

  As a user
  I want to run the Output-Driven Learner on the languages of SL
  So that I can see the course of learning and ultimate results

  Scenario: Print the command line options
    When I run `slodl -h`
    Then it should pass with:
      """
      Usage: slodl [options]
      """

  Scenario: Invalid paradigmatic ranking bias given
    When I run `slodl -p invalid_bias -l ctie -t pool`
    Then it should fail with:
      """
      ERROR: invalid --para_bias value invalid_bias.
      Value must be one of all_high, faith_low, mark_low
      """

  Scenario: Invalid learning compare type given
    When I run `slodl -p mark_low -l invalid_type -t pool`
    Then it should fail with:
      """
      ERROR: invalid --lcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Invalid testing compare type given
    When I run `slodl -p mark_low -l ctie -t invalid_type`
    Then it should fail with:
      """
      ERROR: invalid --tcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Run on the SL typology with no specified options
    Given that file "outputs_typology_1r1s.mar" does not exist
    When I run `slodl`
    Then it should pass with exactly:
      """
      Regenerating the typology data file.
      Learning the SL typology.
      SL learning is finished.
      """
    And a file named "outputs_typology_1r1s.mar" should exist
    And a file named "LgL20.csv" should exist
    And the file "LgL20.csv" should contain:
      """
      Learned: true
      """

  Scenario: Run on the SL typology with an output directory
    Given that file "outputs_typology_1r1s.mar" does not exist
    When I run `slodl -p mark_low -l consistent -t consistent -o mcc`
    Then it should pass with exactly:
      """
      Regenerating the typology data file.
      Learning the SL typology.
      SL learning is finished.
      """
    And a file named "outputs_typology_1r1s.mar" should exist
    And a directory named "mcc" should exist
    And a file named "mcc/LgL20.csv" should exist
    And the following files should exist:
      | mcc/LgL1.csv  | mcc/LgL2.csv  | mcc/LgL3.csv  | mcc/LgL4.csv  |
      | mcc/LgL5.csv  | mcc/LgL6.csv  | mcc/LgL7.csv  | mcc/LgL8.csv  |
      | mcc/LgL9.csv  | mcc/LgL10.csv | mcc/LgL11.csv | mcc/LgL12.csv |
      | mcc/LgL13.csv | mcc/LgL14.csv | mcc/LgL15.csv | mcc/LgL16.csv |
      | mcc/LgL17.csv | mcc/LgL18.csv | mcc/LgL19.csv | mcc/LgL20.csv |
      | mcc/LgL21.csv | mcc/LgL22.csv | mcc/LgL23.csv | mcc/LgL24.csv |

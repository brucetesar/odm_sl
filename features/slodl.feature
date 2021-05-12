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
    When I run `slodl`
    Then it should pass with exactly:
      """
      Calculating the typology.
      Learning the SL typology.
      SL learning is finished.
      """
    And a file named "L20.csv" should exist
    And the file "L20.csv" should contain:
      """
      Learned: true
      """

  Scenario: Run on the SL typology with an output directory
    When I run `slodl -p mark_low -l consistent -t consistent -o mcc`
    Then it should pass with exactly:
      """
      Calculating the typology.
      Learning the SL typology.
      SL learning is finished.
      """
    And a directory named "mcc" should exist
    And the following files should exist:
      | mcc/L1.csv  | mcc/L2.csv  | mcc/L3.csv  | mcc/L4.csv  |
      | mcc/L5.csv  | mcc/L6.csv  | mcc/L7.csv  | mcc/L8.csv  |
      | mcc/L9.csv  | mcc/L10.csv | mcc/L11.csv | mcc/L12.csv |
      | mcc/L13.csv | mcc/L14.csv | mcc/L15.csv | mcc/L16.csv |
      | mcc/L17.csv | mcc/L18.csv | mcc/L19.csv | mcc/L20.csv |
      | mcc/L21.csv | mcc/L22.csv | mcc/L23.csv | mcc/L24.csv |

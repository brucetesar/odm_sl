Feature: odl

  As a user
  I want to run the Output-Driven Learner
  So that I can see the course of learning and ultimate results

  Scenario: Print the command line options
    When I run `odl -h`
    Then it should pass with:
      """
      Usage: odl SYSTEM [options]
      """

  Scenario: No linguistic system code provided
    When I run `odl`
    Then it should fail with:
      """
      ERROR: missing argument for linguistic system.
      Value must be one of sl, pas, multi_stress
      """

  Scenario: Invalid linguistic system code provided
    When I run `odl invalid_system`
    Then it should fail with:
      """
      ERROR: invalid linguistic system invalid_system
      Value must be one of sl, pas
      """

  Scenario: Invalid paradigmatic ranking bias given
    When I run `odl sl -p invalid_bias`
    Then it should fail with:
      """
      ERROR: invalid --para_bias value invalid_bias.
      Value must be one of all_high, faith_low, mark_low
      """

  Scenario: Invalid learning compare type given
    When I run `odl sl -l invalid_type`
    Then it should fail with:
      """
      ERROR: invalid --lcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Invalid testing compare type given
    When I run `odl sl -t invalid_type`
    Then it should fail with:
      """
      ERROR: invalid --tcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Run on the SL typology with no specified options
    When I run `odl sl`
    Then it should pass with exactly:
      """
      Calculating the SL typology.
      Learning the SL typology.
      SL learning is finished.
      """
    And a file named "L20.csv" should exist
    And the file "L20.csv" should contain:
      """
      Learned: true
      """

  Scenario: Run on the SL typology with an output directory
    When I run `odl sl -o mcc`
    Then it should pass with exactly:
      """
      Calculating the SL typology.
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

  Scenario: Run on language L24
    When I run `odl sl -L L24 -o uno`
    Then it should pass with exactly:
      """
      Calculating the SL typology.
      Learning language L24 of the SL typology.
      SL learning is finished.
      """
    And a directory named "uno" should exist
    And a file named "uno/L24.csv" should exist
    And the file "uno/L24.csv" should contain:
      """
       , , , , , , , , , , , \nL24,,,,,,,,,,,
      Learned: true,,,,,,,,,,,
      """
    And the following files should not exist:
      | uno/L1.csv  | uno/L2.csv  | uno/L3.csv  | uno/L4.csv  |
      | uno/L5.csv  | uno/L6.csv  | uno/L7.csv  | uno/L8.csv  |
      | uno/L9.csv  | uno/L10.csv | uno/L11.csv | uno/L12.csv |
      | uno/L13.csv | uno/L14.csv | uno/L15.csv | uno/L16.csv |
      | uno/L17.csv | uno/L18.csv | uno/L19.csv | uno/L20.csv |
      | uno/L21.csv | uno/L22.csv | uno/L23.csv |             |

  Scenario: Run with an invalid language label
    When I run `odl sl -L invalid`
    Then it should fail with exactly:
      """
      Calculating the SL typology.
      ERROR: language invalid was not found in the typology.
      """

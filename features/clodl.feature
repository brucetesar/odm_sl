Feature: clodl

  As a user
  I want to run the Output-Driven Learner from the command line
  So that I can see the course of learning and ultimate result

  Scenario: Print the command line options
    When I run `clodl -h`
    Then it should pass with:
      """
      Usage: clodl LANGLABEL [options]
      """

  Scenario: No language label given
    When I run `clodl`
    Then it should fail with:
      """
      ERROR: missing argument for language label.
      To see all options, run: clodl -h
      """

  Scenario: No report filename given
    When I run `clodl L20`
    Then it should fail with:
      """
      ERROR: missing command line option --report.
      To see all options, run: clodl -h
      """

  Scenario: Run with an invalid language label
    When I run `clodl Invalid -r report -p all_high --clearn ctie --ctest pool`
    Then it should fail with:
      """
      Language Invalid was not found in the typology.
      """

  Scenario: No paradigmatic ranking bias given
    When I run `clodl L20 -r report.csv --clearn ctie --ctest pool`
    Then it should fail with:
      """
      ERROR: missing command line option --para_bias.
      """

  Scenario: Invalid paradigmatic ranking bias given
    When I run `clodl L20 -r report -p invalid_bias --clearn ctie --ctest pool`
    Then it should fail with:
      """
      ERROR: invalid --para_bias value invalid_bias.
      Value must be one of all_high, faith_low, mark_low
      """

  Scenario: No learning compare type given
    When I run `clodl L20 -r report -p mark_low --ctest pool`
    Then it should fail with:
      """
      ERROR: missing command line option --clearn.
      """

  Scenario: Invalid learning compare type given
    When I run `clodl L20 -r report -p mark_low --clearn invalid_type --ctest pool`
    Then it should fail with:
      """
      ERROR: invalid --clearn value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: No testing compare type given
    When I run `clodl L20 -r report -p mark_low --clearn ctie`
    Then it should fail with:
      """
      ERROR: missing command line option --ctest.
      """

  Scenario: Invalid testing compare type given
    When I run `clodl L20 -r report -p mark_low --clearn ctie --ctest invalid_type`
    Then it should fail with:
      """
      ERROR: invalid --ctest value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Run on LgL20
    When I run `clodl L20 -r report -p mark_low --clearn consistent --ctest consistent`
    Then it should pass with:
      """
      L20 learned.
      """
    And a file named "report.csv" should exist
    And the file "report.csv" should contain:
      """
       , , , , , , , , , , , \nL20,,,,,,,,,,,
      Learned: true,,,,,,,,,,,
      """

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
      """

  Scenario: No report filename given
    When I run `clodl L20 -p all_high --lcomp ctie --tcomp pool`
    Then it should fail with:
      """
      ERROR: missing command line option --report.
      """

  Scenario: Run with an invalid language label
    When I run `clodl Invalid -r report -p all_high --lcomp ctie --tcomp pool`
    Then it should fail with:
      """
      Language Invalid was not found in the typology.
      """

  Scenario: No paradigmatic ranking bias given
    When I run `clodl L20 -r report.csv --lcomp ctie --tcomp pool`
    Then it should fail with:
      """
      ERROR: missing command line option --para_bias.
      """

  Scenario: Invalid paradigmatic ranking bias given
    When I run `clodl L20 -r report -p invalid_bias --lcomp ctie --tcomp pool`
    Then it should fail with:
      """
      ERROR: invalid --para_bias value invalid_bias.
      Value must be one of all_high, faith_low, mark_low
      """

  Scenario: No learning compare type given
    When I run `clodl L20 -r report -p mark_low --tcomp pool`
    Then it should fail with:
      """
      ERROR: missing command line option --lcomp.
      """

  Scenario: Invalid learning compare type given
    When I run `clodl L20 -r report -p mark_low --lcomp invalid_type --tcomp pool`
    Then it should fail with:
      """
      ERROR: invalid --lcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: No testing compare type given
    When I run `clodl L20 -r report -p mark_low --lcomp ctie`
    Then it should fail with:
      """
      ERROR: missing command line option --tcomp.
      """

  Scenario: Invalid testing compare type given
    When I run `clodl L20 -r report -p mark_low --lcomp ctie --tcomp invalid_type`
    Then it should fail with:
      """
      ERROR: invalid --tcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Run on LgL20
    When I run `clodl L20 -r report -p mark_low --lcomp consistent --tcomp consistent`
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

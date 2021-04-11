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

  Scenario: No paradigmatic ranking bias given
    When I run `slodl -l ctie -t pool`
    Then it should fail with:
      """
      ERROR: missing command line option --para_bias.
      """

  Scenario: Invalid paradigmatic ranking bias given
    When I run `slodl -p invalid_bias -l ctie -t pool`
    Then it should fail with:
      """
      ERROR: invalid --para_bias value invalid_bias.
      Value must be one of all_high, faith_low, mark_low
      """

  Scenario: No learning compare type given
    When I run `slodl -p mark_low -t pool`
    Then it should fail with:
      """
      ERROR: missing command line option --lcomp.
      """

  Scenario: Invalid learning compare type given
    When I run `slodl -p mark_low -l invalid_type -t pool`
    Then it should fail with:
      """
      ERROR: invalid --lcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: No testing compare type given
    When I run `slodl -p mark_low -l ctie`
    Then it should fail with:
      """
      ERROR: missing command line option --tcomp.
      """

  Scenario: Invalid testing compare type given
    When I run `slodl -p mark_low -l ctie -t invalid_type`
    Then it should fail with:
      """
      ERROR: invalid --tcomp value invalid_type.
      Value must be one of pool, ctie, consistent
      """

  Scenario: Run on the SL typology
    When I run `slodl -p mark_low -l consistent -t consistent`
    Then it should pass with:
      """
      Learning the SL typology.
      SL learning is finished.
      """
    And a file named "LgL20.csv" should exist
    And the file "LgL20.csv" should contain:
      """
      Learned: true
      """

Feature: clodl

  As a user
  I want to run the Output-Driven Learner from the command line
  So that I can see the course of learning and ultimate result

  Scenario: Print the command line options
    When I run `clodl -h`
    Then it should pass with:
      """
      Usage: clodl [options]
      """

  Scenario: No language label given
    When I run `clodl`
    Then it should fail with:
      """
      A label for the language to be learned must be given using
      option --language.
      To see all options, run: clodl -h
      """

  Scenario: No report filename given
    When I run `clodl --language L20`
    Then it should fail with:
      """
      A report filename must be given using option --report.
      To see all options, run: clodl -h
      """

  Scenario: Run with an invalid language label
    When I run `clodl --language Invalid -r report.csv`
    Then it should fail with:
      """
      Language Invalid was not found in the typology.
      """

  Scenario: Run on LgL20
    When I run `clodl --language L20 -r report.csv`
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

Feature: clcrd

  As a user
  I want to run RCD from the command line
  So that I can see the resulting stratified hierarchy of constraints

  Scenario: Print the command line options
    Given that file "temp/LgL20.csv" does not exist
    When I run `clrcd -?`
    Then it should pass with:
      """
      Usage: clrcd [options]
      """

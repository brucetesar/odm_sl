Feature: clmrcd

  As a user
  I want to run MRCD from the command line
  So that I can see the resulting support and constraint hierarchy

  Scenario: Print the command line options
    When I run `clmrcd -?`
    Then it should pass with:
      """
      Usage: clmrcd [options]
      """

  Scenario: No input filename given
    When I run `clmrcd`
    Then it should pass with:
      """
      A filename for the competitions must be given using option -c.
      To see all options, run: clmrcd -?
      """


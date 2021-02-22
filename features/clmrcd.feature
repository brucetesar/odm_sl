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

  Scenario: A single competition with two candidates
    Given a file named "competitions.csv" with:
      """
      input,output,Con1,Con2
      in1,out1,1,0
      in1,out2,0,1
      """
    Given a file named "winners.csv" with:
      """
      input,output
      in1,out1
      """
    When I run `clmrcd -c competitions.csv -w winners.csv`
    Then it should pass with:
      """
      Consistent
      [0:Con1] [1:Con2]
      """

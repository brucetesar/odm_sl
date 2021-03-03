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
    When I run `clmrcd -l consistent`
    Then it should fail with:
      """
      A filename for the competitions must be given using option -c.
      To see all options, run: clmrcd -h
      """

  Scenario: No loser selection type given
    When I run `clmrcd -c competitions.csv -w winners.csv`
    Then it should fail with:
      """
      Must specify a valid loser selection type with -l
      """

  Scenario: A single competition with two candidates
    Given a file named "competitions.csv" with:
      """
      input,output,Con1,Con2
      in1,out1,0,1
      in1,out2,1,0
      """
    Given a file named "winners.csv" with:
      """
      input,output
      in1,out1
      """
    When I run `clmrcd -l consistent -c competitions.csv -w winners.csv`
    Then it should pass with:
      """
      Consistent
      [Con1] [Con2]
      """
    When I run `clmrcd -l pool -c competitions.csv -w winners.csv -b fl`
    Then it should pass with:
      """
      Consistent
      [Con1] [Con2]
      """
    When I run `clmrcd -l ctie -c competitions.csv -w winners.csv -b fl`
    Then it should pass with:
      """
      Consistent
      [Con1] [Con2]
      """

  Scenario: Two competitions and two winners
    Given a file named "competitions.csv" with:
      """
      input,output,M:1,M:2,F:1,F:2
      in1,out1,0,1,0,0
      in1,out2,1,0,1,0
      in2,out1,0,1,1,0
      in2,out2,1,0,0,0
      """
    Given a file named "winners.csv" with:
      """
      input,output
      in1,out1
      in2,out2
      """
    When I run `clmrcd -l ctie -b fl -c competitions.csv -w winners.csv`
    Then it should pass with:
      """
      Consistent
      [F:1] [M:1 M:2] [F:2]
      """

  Scenario: A specified output file
    Given a file named "competitions.csv" with:
      """
      input,output,M:1,M:2,F:1,F:2
      in1,out1,0,1,0,0
      in1,out2,1,0,1,0
      in2,out1,0,1,1,0
      in2,out2,1,0,0,0
      """
    Given a file named "winners.csv" with:
      """
      input,output
      in1,out1
      in2,out2
      """
    When I run `clmrcd -l ctie -b fl -c competitions.csv -w winners.csv -r report.csv`
    Then it should pass with:
      """
      Consistent
      [F:1] [M:1 M:2] [F:2]
      """
    And a file named "report.csv" should exist
    And the file "report.csv" should contain:
      """
      ERC#,Input,Winner,Loser,F:1,M:1,M:2,F:2
      "",in1,out1,out2,W,W,L,
      "",in2,out2,out1,W,L,W,
      """

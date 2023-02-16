Feature: clmrcd

  As a user
  I want to run MRCD from the command line
  So that I can see the resulting support and constraint hierarchy

  Scenario: Print the command line options
    When I run `clmrcd -?`
    Then it should pass
    And STDOUT should include:
      """
      Usage: clmrcd [options]
      """

  Scenario: No input filename given
    When I run `clmrcd -l consistent`
    Then it should fail
    And STDOUT should be exactly:
      """
      A filename for the competitions must be given using option -c.
      To see all options, run: clmrcd -h
      """

  Scenario: No loser selection type given
    When I run `clmrcd -c competitions.csv -w winners.csv`
    Then it should fail
    And STDOUT should be exactly:
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
    When I run `clmrcd -c competitions.csv -w winners.csv -l consistent`
    Then it should pass
    And STDOUT should be exactly:
      """
      Consistent
      [Con1] [Con2]
      """
    When I run `clmrcd -c competitions.csv -w winners.csv -l pool -b fl`
    Then it should pass
    And STDOUT should be exactly:
      """
      Consistent
      [Con1] [Con2]
      """
    When I run `clmrcd -c competitions.csv -w winners.csv -l ctie -b fl`
    Then it should pass
    And STDOUT should be exactly:
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
    When I run `clmrcd -c competitions.csv -w winners.csv -l ctie -b fl`
    Then it should pass
    And STDOUT should be exactly:
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
    When I run `clmrcd -c competitions.csv -w winners.csv -l ctie -b fl -r report.csv`
    Then it should pass
    And STDOUT should be exactly:
      """
      Consistent
      [F:1] [M:1 M:2] [F:2]
      """
    And a file named "report.csv" should exist
    And the file named "report.csv" should include:
      """
      ERC#,Input,Winner,Loser,F:1,M:1,M:2,F:2
      "",in1,out1,out2,W,W,L,
      "",in2,out2,out1,W,L,W,
      """

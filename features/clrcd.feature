Feature: clcrd

  As a user
  I want to run RCD from the command line
  So that I can see the resulting stratified hierarchy of constraints

  Scenario: Print the command line options
    When I run `clrcd -?`
    Then it should pass with:
      """
      Usage: clrcd [options]
      """

  Scenario: Two constraints one ERC
    Given a file named "support1.csv" with:
      """
      ,Con1,Con2
      erc1,W,L
      """
    When I run `clrcd -e support1.csv`
    Then it should pass with:
      """
      {0:Con1} >> {1:Con2}
      """
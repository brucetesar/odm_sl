Feature: clrcd

  As a user
  I want to run RCD from the command line
  So that I can see the resulting stratified hierarchy of constraints

  Scenario: Print the command line options
    When I run `clrcd -?`
    Then it should pass with:
      """
      Usage: clrcd [options]
      """

  Scenario: No input filename given
    When I run `clrcd`
    Then it should pass with:
      """
      A filename for the ERCs must be given using option -e.
      To see all options, run: clrcd -?
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
      Consistent
      [Con1] [Con2]
      """

  Scenario: Empty support
    Given a file named "empty_support.csv" with:
      """
      ,Con1,Con2
      """
    When I run `clrcd -e empty_support.csv`
    Then it should pass with:
      """
      Consistent
      [Con1 Con2]
      """

  Scenario: Inconsistent ERCs
    Given a file named "inconsistent_support.csv" with:
      """
      ,Con1,Con2
      erc1,W,L
      erc2,L,W
      """
    When I run `clrcd -e inconsistent_support.csv`
    Then it should pass with:
      """
      Inconsistent
      """

  Scenario: A faith-low ranking bias
    Given a file named "support2.csv" with:
      """
      ,Con1,Con2,F:Con3
      erc1,W,L,W
      """
    When I run `clrcd --bias fl -e support2.csv`
    Then it should pass with:
      """
      Consistent
      [Con1] [Con2] [F:Con3]
      """

  Scenario: An all-high ranking bias with faithfulness constraints
    Given a file named "support3.csv" with:
      """
      ,Con1,Con2,F:Con3
      erc1,W,L,W
      """
    When I run `clrcd -b ah -e support3.csv`
    Then it should pass with:
      """
      Consistent
      [Con1 F:Con3] [Con2]
      """

  Scenario: A mark-low ranking bias
    Given a file named "support4.csv" with:
      """
      ,Con1,Con2,F:Con3
      erc1,W,L,W
      """
    When I run `clrcd -b ml -e support4.csv`
    Then it should pass with:
      """
      Consistent
      [F:Con3] [Con1 Con2]
      """

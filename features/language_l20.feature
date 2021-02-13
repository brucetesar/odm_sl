Feature: Language L20 is learned

  As a user
  I want to run the learning algorithm on Language L20
  So that I can verify that it is learned correctly

  Scenario: learn the grammar for Language L20
    Given that file "temp/LgL20.csv" does not exist
    When I run `learn_l20_1r1s`
    Then the file "temp/sl/LgL20.csv" is produced
    And "temp/sl/LgL20.csv" is identical to "test/fixtures/LgL20_expected.csv"

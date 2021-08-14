Feature: typology

  As a user
  I want to run the typology generator
  So that I can see the words of each language in the typology

  Scenario: Print the command line options
    When I run `typology -h`
    Then it should pass with:
      """
      Usage: typology SYSTEM [options]
      """

  Scenario: No linguistic system code provided
    When I run `typology`
    Then it should fail with:
      """
      ERROR: missing argument for linguistic system.
      Value must be one of sl, pas, multi_stress
      """

  Scenario: Invalid linguistic system code provided
    When I run `odl invalid_system`
    Then it should fail with:
      """
      ERROR: invalid linguistic system invalid_system
      Value must be one of sl, pas, multi_stress
      """

  Scenario: Calculate the SL typology with no specified options
    When I run `typology sl`
    Then it should pass with exactly:
      """
      Calculating the SL typology.
      """
    And a directory named "lang_1r1s" should exist
    And a file named "lang_1r1s/L20.txt" should exist
    And the file "lang_1r1s/L20.txt" should contain:
      """
      r1-s1 s.-s. --> S.s.   NoLong:0 WSP:0 ML:0 MR:1 IDStress:1 IDLength:0
      """

  Scenario: Calculate the SL typology with a specified output directory
    When I run `typology sl -o sl_folder`
    Then it should pass with exactly:
      """
      Calculating the SL typology.
      """
    And a directory named "sl_folder/lang_1r1s" should exist
    And a file named "sl_folder/lang_1r1s/L20.txt" should exist
    And the file "sl_folder/lang_1r1s/L20.txt" should contain:
      """
      r1-s1 s.-s. --> S.s.   NoLong:0 WSP:0 ML:0 MR:1 IDStress:1 IDLength:0
      """
    And a file named "sl_folder/sl_system.yml" should exist

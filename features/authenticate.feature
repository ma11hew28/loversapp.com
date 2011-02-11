Feature: user authenticates himself

  As a user
  I want to authenticate myself
  So that I can use the application

  Scenario: initial authentication
    Given I'm not already authenticated
    When I log in
    Then I should be an app user
    # Then I should be authenticated

  Scenario: deauthorize app
    Given I'm an app user
    When I deauthorize the app
    Then I should not be an app user

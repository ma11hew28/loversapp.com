Feature: user authenticates himself

  As a user
  I want to authenticate myself
  So that I can use the application

  Scenario: anonymous user
    Given I'm not an app user
    When I go to the canvas page
    Then I should not be authenticated

  Scenario: initial authentication
    Given I'm an app user
    When I go to the canvas page
    Then I should be authenticated

  Scenario: subsequent authentication
    Given I'm already authenticated
    When I go to the canvas page
    Then I should be remembered

  Scenario: authentication error
    Given I'm a malicious user
    When I go to the canvas page
    Then I should get a Facebook::AuthenticationError

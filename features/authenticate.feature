Feature: user authenticates himself

  As a user
  I want to authenticate myself
  So that I can use the application

  @wip
  Scenario: initially authenticates
    Given I'm not already authenticated
    When I go to the canvas page
    Then I should be an app user
    # Then I should be authenticated

  Scenario: subsequently authenticates
    Given I'm remembered
    When I click on the Lovers tab
    Then I should be authenticated

  Scenario: deauthorizes app
    Given I'm an app user
    When I deauthorize the app
    And I should not be an app user

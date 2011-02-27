@wip
Feature: user manages apprequests

  As a user
  I want to view, and accept or delete my apprequests
  So that I can interact with other users

  Background: Logged in
    Given I'm logged in
    # And I have the following apprequests

  Scenario: view apprequests
    When I view my apprequests
    Then I should see "3" apprequests

  # Scenario: delete apprequest
  #   When I delete apprequest "1234"
  #   And I view my apprequests
  #   Then I should see "2" apprequests

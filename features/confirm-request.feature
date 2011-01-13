Feature: user confirms request

  As a user
  I want to confirm a request
  So that I can express my love

  # TODO: Get FB's feedback msgs. Add FB's block condition.

  Scenario: successful confirmation
    Given I'm logged in
    And I have already received this request
    And I'm not already in this relationship
    When I confirm this request
    Then this request should be deleted
    And this relationship should be created
    And the response code should be "1"
    # Request confirmed. [See what Facebook puts here.]

  Scenario: no request - no relationship
    Given I'm logged in
    And I haven't already received this request
    And I'm not already in this relationship
    When I confirm this request
    Then the response code should be "0"
    # This request doesn't exist. <Send this request>.

  Scenario: relationship already exists
    Given I'm logged in
    And I'm already in this relationship
    When I confirm this request
    Then the response code should be "2"
    # This relationship already exists.

  Scenario: logged out
    Given I'm logged out
    When I send this request
    Then the response code should be 9

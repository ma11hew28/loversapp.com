Feature: user confirms request

  Background: Logged in
    Given I'm logged in
    And I've sent the following requests:
      | rid | uid |
      | 3   | 10  |
    And I've received the following requests:
      | rid | uid |
      | 2   | 12  |
    And I've hidden the following requests:
      | rid | uid |
      | 1   | 15  |
    And I'm in the following relationships:
      | rid | uid |
      | 4   | 11  |

  # TODO: Get FB's feedback msgs. Add FB's block condition.

  Scenario: successful confirmation
    When I confirm a "2" request from user "12"
    Then I should have "0" received requests
    And I should have "2" relationships
    And the response code should be "1"
    # Request confirmed. [See what Facebook puts here.]

  Scenario: hidden confirmation
    When I confirm a "1" request from user "15"
    Then I should have "0" hidden requests
    And I should have "2" relationships
    And the response code should be "1"
    # Request confirmed. [See what Facebook puts here.]

  Scenario: no request - no relationship
    When I confirm a "0" request from user "14"
    Then I should have "1" relationship
    And the response code should be "2"
    # This request doesn't exist. <Send this request>.

  Scenario: relationship already exists
    When I confirm a "4" request from user "11"
    Then I should have "1" relationship
    And the response code should be "0"
    # This relationship already exists.

#   Scenario: logged out
#     Given I'm logged out
#     When I confirm a "2" request from user "12"
#     Then the response code should be "9"

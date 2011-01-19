Feature: user hides request

  # Facebook's feedback messages:
  # Request hidden. Take action later on the <Requests page>. <Don't know Matt Di Pasquale?>
  # This friend request is already hidden.
  # Thanks. This person won't be able to send you any more friend requests. <Undo>.
  # Unblocked. This person can send you friend requests again.

  # We work similarly but don't use blacking at all.
  # TODO: Add Facebook's block condition to requests.
  # Test the block condition out on Facebook.
  # Also, look at FB's AJAX responses in Firebug.

  Background: Logged in
    Given I'm logged in
    And I've hidden the following requests:
      | rid | uid |
      | 3   | 10  |
    And I've received the following requests:
      | rid | uid |
      | 2   | 12  |
    And I'm in the following relationships:
      | rid | uid |
      | 4   | 11  |

  Scenario: successful hide
    When I hide a "2" request from user "12"
    Then I should have "2" hidden requests
    And I should have "0" received requests
    And the response code should be "1"
    # Request hidden. Take action later from the <Hidden Requests section below>.

  Scenario: already hidden
    When I hide a "3" request from user "10"
    Then I should have "1" hidden request
    And the response code should be "0"
    # This request is already hidden.

  Scenario: no request - no relationship
    When I hide a "0" request from user "14"
    Then I should have "1" hidden request
    And the response code should be "2"
    # This request doesn't exist.

  Scenario: relationship already exists
    When I hide a "4" request from user "11"
    Then I should have "1" hidden request
    And the response code should be "3"
    # This relationship already exists. <Remove it>.


# Feature: user removes request

  Scenario: successful remove
    When I remove a "2" request from user "12"
    Then I should have "0" received requests
    And the response code should be "1"

  Scenario: hidden request
    When I remove a "3" request from user "10"
    Then I should have "0" hidden requests
    And the response code should be "1"

  Scenario: no request
    When I remove a "0" request from user "14"
    Then I should have "1" received request
    And the response code should be "0"

  # TDOD: Implement if Facebook does
  # Scenario: relationship exists

# Feature: user removes relationship

  Scenario: successful remove
    When I remove a "4" relationship from user "11"
    Then I should have "0" relationships
    And the response code should be "1"

  Scenario: no relationship
    When I remove a "0" request from user "14"
    Then I should have "1" relationship
    And the response code should be "0"


# [x] You cannot create a relationship with yourself.
#   http://static.ak.fbcdn.net/rsrc.php/zY/r/wl6KMCh80w9.png
#     background-position: 0px -59px; height: 11px; width: 11px;
# We will request confirmation of this relationship from Matt Di Pasquale upon saving.
# Your changes have been saved.
# 

Feature: user sends request

  As a user
  I want to send a relationship request
  So that I can express my love

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

  Scenario: successful request
    When I send a "0" request to user "14"
    Then I should have "2" sent requests
    And the response code should be "1"

  Scenario: request already sent
    When I send a "3" request to user "10"
    Then I should have "1" sent requests
    And the response code should be "0"

  Scenario: request already received
    When I send a "2" request to user "12"
    Then I should have "0" received requests
    And I should have "2" relationships
    And the response code should be "2"

  Scenario: request already received (hidden)
    When I send a "1" request to user "15"
    Then I should have "0" hidden requests
    And I should have "2" relationships
    And the response code should be "2"

  Scenario: same relationship already exists
    When I send a "4" request to user "11"
    Then I should have "1" sent requests
    And the response code should be "3"

  # The front-end UI will have all my reqs & rels loaded. So, it should
  # confirm, "You're already [in a complicated relationship with] Matt Di
  # Pasquale. You may only be in one type of relationship with one person at a
  # time. Are you sure you want to request to be [Married] instead? We will
  # only change your relationship if Matt confirms this request."
  Scenario: different relationship already exists
    When I send a "3" request to user "11"
    Then I should have "2" sent requests
    And the response code should be "1"
    
  # # TODO: How do we generalize this for all features?
  # Scenario: logged out
  #   Given I'm logged out
  #   When I send this request
  #   Then the response code should be 9

  # Scenario: successful request
  #   When I send a "0" request to user "124"
  #   Given I'm logged in
  #   And I haven't already sent this request
  #   And I haven't already received this request
  #   And I'm not already in this relationship
  #   When I send this request
  #   Then this request should be created
  #   And the response code should be 1
  #
  # Scenario: request already sent
  #   Given I'm logged in
  #   And I have already sent this request
  #   When I send this request
  #   Then the response code should be 0
  #
  # Scenario: request already received
  #   Given I'm logged in
  #   And I have already received this request
  #   And I'm not already in this relationship
  #   When I send this request
  #   Then this request should be deleted
  #   And this relationship should be created
  #   And the response code should be 2
  #
  # Scenario: relationship already exists
  #   Given I'm logged in
  #   And I'm already in this relationship
  #   When I send this request
  #   And the response code should be 3

  # Scenario Outline: send request
  #   Given I <sent> already sent this request
  #   And I <recv> already received this request
  #   And I <rel> already in this relationship
  #   When I send this request
  #   Then the response code should be <resp>
  #
  #   Scenarios: no requests or relationships
  #     | sent    | recv    | rel    | resp |
  #     | haven't | haven't | am not | 1    |
  #
  #   Scenarios: request already sent
  #     | sent    | recv    | rel    | resp |
  #     | have    | haven't | am not | 0    |
  #
  #   Scenarios: request already received
  #     | sent    | recv    | rel    | resp |
  #     | haven't | have    | am not | q    |
  #
  #   Scenarios: already in this relationship
  #     | sent    | recv    | rel    | resp |
  #     | haven't | haven't | am     | l    |

# Stories:
#
# user loads requests & relationships
#
# user sends love to a friend
# user buys gift for friend
#
#
# user confirms request
# user ignores request
#
# user ends a relationship
#
# user views a profile
# user views relationships in common
#
# user views leaderboard (most loving & most loved)
#

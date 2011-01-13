Feature: user hides request

  As a user
  I want to hide a request
  So that I can focus on those I love

  # Facebook's feedback messages:
  # Request hidden. Take action later on the <Requests page>. <Don't know Matt Di Pasquale?>
  # This friend request is already hidden.
  # Thanks. This person won't be able to send you any more friend requests. <Undo>.
  # Unblocked. This person can send you friend requests again.

  # We work similarly but don't use blacking at all.
  # TODO: Add Facebook's block condition to requests.
  # Test the block condition out on Facebook.
  # Also, look at FB's AJAX responses in Firebug.

  Scenario: successful hide
    Given I'm logged in
    And I have already received this request
    When I hide this request
    Then this request should be hidden
    And the response code should be "1"
    # Request hidden. Take action later from the <Hidden Requests section below>.

  Scenario: already hidden
    Given I'm logged in
    And I have already hidden this request
    When I hide this request
    Then the response code should be "0"
    # This request is already hidden.

  Scenario: no request - no relationship
    Given I'm logged in
    And I haven't already received this request
    And I'm not already in this relationship
    When I hide this request
    Then the response code should be "2"
    # This request doesn't exist.

  Scenario: relationship already exists
    Given I'm logged in
    And I'm already in this relationship
    When I ignore this request
    Then the response code should be "3"
    # This relationship already exists. <Remove it>.

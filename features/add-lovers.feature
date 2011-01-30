Feature: user adds friends as lovers

  As a user
  I want to be in multiple relationships
  So that I can express my love
  
  # The system doesn't prevent the race condition where two symmetrical reqs
  # happen simultaneously. That's OK because it does guarantees unique rels.
  #
  # Facebook's feedback messages:
  # Request hidden. Take action later on the <Requests page>. <Don't know Matt Di Pasquale?>
  # [x] You cannot create a relationship with yourself.
  #   http://static.ak.fbcdn.net/rsrc.php/zY/r/wl6KMCh80w9.png
  #     background-position: 0px -59px; height: 11px; width: 11px;
  # We will request confirmation of this relationship from Matt Di Pasquale upon saving.
  # Your changes have been saved.
  # This friend request is already hidden.
  # Thanks. This person won't be able to send you any more friend requests. <Undo>.
  # Unblocked. This person can send you friend requests again.
  # TODO: Get the rest of Facebook's feedback messages.
  #
  # We work similarly but don't use blacking at all.
  # TODO: Add Facebook's block condition to requests.
  # Test the block condition out on Facebook.
  # TODO: Examine FB's AJAX responses in Firebug.
  # TODO: Improve response codes & feedback messages.
  # TODO: Use wait, multi, exec, etc. to ensure transactions.
  # TODO: Show sentReqs and allow option to revoke them.

  Background: Logged in
    Given I'm logged in
    And I've sent the following requests:
      | rid | uid |
      | 3   | 10  |
    And I've received the following requests:
      | rid | uid |
      | 2   | 12  |
      | 0   | 11  |
    And I've hidden the following requests:
      | rid | uid |
      | 1   | 15  |
    And I'm in the following relationships:
      | rid | uid |
      | 2   | 16  |
      | 4   | 11  |

  Scenario Outline: send request
    When I send a "<rid>" request to user "<uid>"
    Then I should have "<sent>" sent requests
    And I should have "<recv>" received requests
    And I should have "<hidn>" hidden requests
    And I should have "<rels>" relationships
    And the response code should be "<code>"

    # Request confirmed. [See what Facebook puts here.]
    Scenarios: successful request send
      | rid | uid | sent | recv | hidn | rels | code |
      | 0   | 14  | 2    | 2    | 1    | 2    | 1    |
    
    Scenarios: request already sent
      | rid | uid | sent | recv | hidn | rels | code |
      | 3   | 10  | 1    | 2    | 1    | 2    | 0    |

    Scenarios: request already received
      | rid | uid | sent | recv | hidn | rels | code |
      | 2   | 12  | 1    | 1    | 1    | 3    | 2    |
      | 1   | 15  | 1    | 2    | 0    | 3    | 2    |

    Scenarios: same relationship already exists
      | rid | uid | sent | recv | hidn | rels | code |
      | 4   | 11  | 1    | 2    | 1    | 2    | 3    |

    # The front-end UI will have all my reqs & rels loaded. So, it should
    # confirm, "You're already [in a complicated relationship with] Matt Di
    # Pasquale. You may only be in one type of relationship with one person at a
    # time. Are you sure you want to request to be [Married] instead? We will
    # only change your relationship if Matt confirms this request."
    Scenarios: different relationship already exists
      | rid | uid | sent | recv | hidn | rels | code |
      | 3   | 11  | 2    | 2    | 1    | 2    | 1    |

 
  Scenario Outline: hide request
    When I hide a "<rid>" request from user "<uid>"
    Then I should have "<recv>" received requests
    And I should have "<hidn>" hidden requests
    And the response code should be "<code>"

    # Request hidden. Take action later from the <Hidden Requests section below>. 
    Scenarios: successful hide
      | rid | uid | recv | hidn | code |
      | 2   | 12  | 1    | 2    | 1    |
    
    # This request is already hidden.
    Scenarios: already hidden
      | rid | uid | recv | hidn | code |
      | 1   | 15  | 2    | 1    | 0    |

    # This request doesn't exist.    
    Scenarios: no request - no relationship
      | rid | uid | recv | hidn | code |
      | 0   | 14  | 2    | 1    | 2    |

    # This relationship already exists. <Remove it>.
    Scenarios: relationship already exists
      | rid | uid | recv | hidn | code |
      | 4   | 11  | 2    | 1    | 3    |


  Scenario Outline: confirm request
    When I confirm a "<rid>" request from user "<uid>"
    Then I should have "<recv>" received requests
    And I should have "<hidn>" hidden requests
    And I should have "<rels>" relationships
    And the response code should be "<code>"

    # Request confirmed. [See what Facebook puts here.]
    Scenarios: successful confirmation
      | rid | uid | recv | hidn | rels | code |
      | 2   | 12  | 1    | 1    | 3    | 1    |
      | 1   | 15  | 2    | 0    | 3    | 1    |

    # This request doesn't exist. <Send this request>.
    Scenarios: no request - no relationship
      | rid | uid | recv | hidn | rels | code |
      | 0   | 14  | 2    | 1    | 2    | 2    |

    # This relationship already exists.
    # Or, relationship updated
    Scenarios: relationship already exists
      | rid | uid | recv | hidn | rels | code |
      | 4   | 11  | 2    | 1    | 2    | 0    |
      | 0   | 11  | 1    | 1    | 2    | 0    |


  Scenario Outline: remove request
    When I remove a "<rid>" request from user "<uid>"
    Then I should have "<recv>" received requests
    And I should have "<hidn>" hidden requests
    And the response code should be "<code>"

    Scenarios: successful remove
      | rid | uid | recv | hidn | code |
      | 2   | 12  | 1    | 1    | 1    |
      | 1   | 15  | 2    | 0    | 1    |

    Scenarios: no request to remove
      | rid | uid | recv | hidn | code |
      | 0   | 14  | 2    | 1    | 0    |

    # TDOD: Implement if Facebook does
    # Scenario: relationship exists


  Scenario Outline: remove relationship
    When I remove a "<rid>" relationship with user "<uid>"
    And I should have "<rels>" relationships
    And the response code should be "<code>"

    Scenarios: successful remove relationship
      | rid | uid | rels | code |
      | 4   | 11  | 1    | 1    |

    Scenarios: no relationship to remove
      | rid | uid | rels | code |
      | 0   | 14  | 2    | 0    |
 
#   Scenario: logged out
#     Given I'm logged out
#     When I confirm a "2" request from user "12"
#     Then the response code should be "8"
#
# More Stories:
#
# user loads requests & relationships
#
# user sends love to a friend
# user buys gift for friend
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

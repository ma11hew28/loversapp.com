Feature: user sends gifts to friends

  As a user
  I want to send gifts to friends
  So that I can express my love and earn points

  Background: Logged in
    # TODO: Should we use fixtures or factories instead?
    Given the following users exist:
      | uid |
      | 1   |
      | 2   |
      | 3   |
      | 4   |
    And user "3" has sent gift "1" to user "4"

  Scenario Outline: send gift and earn points
    Given user "<uid>" has sent gift "<gid>" to user "<tid>"
    Then user "<uid>" should have "<sent>" sent gifts
    And user "<tid>" should have "<recv>" received gifts
    And user "<uid>" should have "<ppts>" proactive points
    And user "<tid>" should have "<apts>" attracted points

    Scenarios: successful gift send
      | uid | gid | tid | sent | recv | ppts | apts |
      | 1   | 0   | 2   | 1    | 1    | 1    | 1    |
      | 1   | 1   | 2   | 1    | 1    | 11   | 11   |
      | 1   | 2   | 2   | 1    | 1    | 100  | 100  |
      | 1   | 3   | 2   | 1    | 1    | 3305 | 3305 |

    Scenarios: send and receive more gifts
      | uid | gid | tid | sent | recv | ppts | apts |
      | 3   | 0   | 4   | 2    | 2    | 12   | 12   |
      | 3   | 1   | 4   | 2    | 2    | 22   | 22   |
      | 3   | 2   | 4   | 2    | 2    | 111  | 111  |
      | 3   | 3   | 4   | 2    | 2    | 3316 | 3316 |

  Scenario: calculate points
    Given the following gifts have been sent:
      | uid | gid | tid |
      | 1   | 0   | 2   |
      | 1   | 1   | 2   |
      | 1   | 2   | 2   |
      | 1   | 3   | 2   |
      | 3   | 1   | 4   |
      | 4   | 2   | 3   |
    When the points are calculated & saved for each user
    Then the points should be:
      | uid | pts  | pro  | atr  |
      | 1   | 3417 | 3417 | 0    |
      | 2   | 3417 | 0    | 3417 |
      | 3   | 122  | 22   | 100  |
      | 4   | 122  | 100  | 22   |

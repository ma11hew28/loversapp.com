Feature: user sends gifts to friends

  As a user
  I want to send gifts to friends
  So that I can express my love

  Background: Logged in
    Given I'm logged in
    And I've sent the following gifts:
      | gid | uid |
      | 1   | 11  |

  Scenario Outline: send gift and earn points
    When I send a "<gid>" gift to user "<uid>"
    Then I should have "<sent>" sent gifts
    And I should have "<pts>" points
    And user "<uid>" should have "<pt2>" points

    Scenarios: successful gift send
      | gid | uid | sent | pts  | pt2  |
      | 0   | 10  | 2    | 12   | 1    |
      | 1   | 11  | 2    | 22   | 22   |
      | 2   | 12  | 2    | 111  | 100  |
      | 3   | 13  | 2    | 3316 | 3305 |

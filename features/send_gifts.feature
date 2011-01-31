Feature: user sends gifts to friends

  As a user
  I want to send gifts to friends
  So that I can express my love
 
  Background: Logged in
    Given I'm logged in
    And I've sent the following gifts:
      | gid | uid |
      | 3   | 10  |

  Scenario Outline: send gift
    When I send a "<gid>" gift to user "<uid>"
    Then I should have "<sent>" sent gifts

    Scenarios: successful gift send
      | gid | uid | sent |
      | 0   | 14  | 2    |
      | 3   | 10  | 2    |

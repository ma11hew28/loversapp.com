Feature: user sends & confirms or ignores relationship requests

  As a user
  I want to add friends as lovers
  So that I can spread the love

  Scenario: send request
    Given I have not yet sent this request
    And I have not yet received this request
    And I am not yet in this relationship
    When I send this request
    Then I should see 1


Stories:

user loads requests & relationships

user sends love to a friend
user buys gift for friend


user confirms request
user ignores request

user ends a relationship

user views a profile
user views relationships in common

user views leaderboard (most loving & most loved)

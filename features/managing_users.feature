Feature: User creation
  Scenario: Visitor signs up, tries to sign in, confirms email, and signs out
    Given I am on the "sign_in" page
    When I click "Sign up"
    And I enter the following user information:
      | email    | foo@bar.org      |
      | password | goofballgoofball |
    And I navigate to the "sign_in" page
    And I sign in with the following information:
      | email    | foo@bar.org      |
      | password | goofballgoofball |
    Then I should see a flash that says "Confirm your email"
    And I should see a link in the email that takes me back to the application and confirms my account
    And I should be logged in

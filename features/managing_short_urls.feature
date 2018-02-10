Feature: Managing short URLs
  Scenario: Adding a short URL
    Given the short URL "foobar" does not exist
    When I click "Create a short URL"
    And I fill in the form with the following details:
      | slug     | foobar                  |
      | redirect | https://www.example.com |
    And I click "Create"
    Then I should see a list of short URLs that includes "foobar"

  Scenario: Editing a short URL
    Given the following short URLs exist:
      | slug   | redirect                     |
      | 010101 | https://www.flyinggrizzly.io |
      | asdf12 | https://www.wikipedia.org    |
    When I click "View all short URLs"
    And I click "010101"
    And I click "Edit"
    And I fill in the form with the following details:
      | redirect | https://www.example.com |
    And I click "Update"
    And I visit the page for short URL "010101"
    Then I should see that it redirects to "https://www.example.com"

  Scenario: Deleting a short URL
    Given the following short URLs exist:
      | slug   | redirect                     |
      | 010101 | https://www.flyinggrizzly.io |
      | asdf12 | https://www.wikipedia.org    |
    When I visit the page for short URL "010101"
    And I click "Delete"
    Then I should see a list of short URLs that does not include "010101"
    And "010101" should be removed from S3
    And the Cloudfront cache for "010101" should be invalidated
    And accessing "/010101" on the URL shortener endpoint should result in an error

  Scenario: Publishing a short URL
    Given the following short URLs exist:
      | slug   | redirect                     |
      | 010101 | https://www.flyinggrizzly.io |
    And the short URL "010101" is not published
    When I visit the page for short URL "010101"
    And I click "Publish to AWS"
    Then I should see its publication status is "Published"
    And "010101" should be published to S3
    And the Cloudfront cache for "010101" should be invalidated
    And accessing "/010101" on the URL shortener endpoint should redirect me to "https://www.flyinggrizzly.io"

  Scenario: Unpublishing a short URL
    Given the following short URLs exist:
      | slug   | redirect                     |
      | 010101 | https://www.flyinggrizzly.io |
    And the short URL "010101" is published
    When I visit the page for short URL "010101"
    And I click "Unpublish from AWS"
    Then I should see its publication status is "Unpublished"
    And "010101" should be removed from S3
    And the Cloudfront cache for "010101" should be invalidated
    And accessing "/010101" on the URL shortener endpoint should result in an error

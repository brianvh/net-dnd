Performing finds against a given DND host, for multiple users, is another goal of
the Net::DND library. Developers and users need the ability to start, and manage,
Net::DND connections and issue finds that return proper multi-user results.

Story: Finding multiple DND users
  As a developer
  I want to connect to a DND server
  So that I can find profiles for user names that match multiple users

  Scenario: Developer finds multiple users, by name
    Given a connection to the Alumni DND server
    When performing a find for user 'test account'
    Then it closes the connection
    And it returns an Array with '5' items
    And the last element of the array is a Profile
    And the 'class' attribute of the last element is '01'

  Scenario: Developer tries to find multiple users, by name, and fails
    Given a connection to the Alumni DND server
    When performing a find for user 'no user'
    Then it closes the connection
    And it returns an Array with '0' items

Performing finds against a given DND host, for single users, is a primary goal of
the Net::DND library. Developers and users need the ability to start, and manage,
Net::DND connections and issue single user finds that return proper results.

Story: Finding a single DND user
  As a developer
  I want to connect to a DND server
  So that I can find single DND users and their profile information

  Scenario: Developer finds a single user by name
    Given a DND connection to 'dnd.dartmouth.edu' with fields 'name,uid,dctsnum'
    When performing a find for user 'throckie' with a one of 'true'
    Then it closes the connection
    And it returns a single profile object
    And it should have the name 'Throckmorton P. Scribblemonger'
    And it should have the uid '58789'
    And it should have the dctsnum 'HDZ50097'
  
  Scenario: Developer can not find a single user by name
    Given a DND connection to 'dnd.dartmouth.edu' with fields 'name,uid,dctsnum'
    When performing a find for user 'bad name' with a one of 'true'
    Then it closes the connection
    And it returns a nil result

  Scenario: Developer finds a single user by uid
    Given a DND connection to 'dnd.dartmouth.edu' with fields 'name,dctsnum'
    When performing a find for user '58789' with a one of 'true'
    Then it closes the connection
    And it returns a single profile object
    And it should have the name 'Throckmorton P. Scribblemonger'
    And it should have the dctsnum 'HDZ50097'

  Scenario: Developer finds a single user by dctsnum
    Given a DND connection to 'dnd.dartmouth.edu' with fields 'name,uid'
    When performing a find for user 'Z50097' with a one of 'true'
    Then it closes the connection
    And it returns a single profile object
    And it should have the name 'Throckmorton P. Scribblemonger'
    And it should have the uid '58789'
  

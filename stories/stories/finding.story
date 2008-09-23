Performing finds against a given DND host is the real purpose of the Net::DND library. Developers and
users need the ability to start, and manage, Net::DND sessions and issue find commands that will return
proper results, whether the find is a 

Story: Performing Net::DND finds
  As a developer
  I want to use a Net::DND session
  So that I can lookup/verify information about DND entries

  Scenario: Developer finds a single user by name
    Given 'a Net::DND connection to host "dnd.dartmouth.edu" with field_list "name, uid, did"'
    When 'performing a find with look_for "throckie" and one "true"'
    Then 'returns a single profile object'
    And 'it should have name "Throckmorton P. Scribblemonger"'
    And 'it should have uid "58789"'
    And 'it should have did "HDZ50097"'
    And 'the connection should be closed'
  
  # Scenario: Developer can not find a single user by name
  #   Given a Net::DND connection to host: 'dnd.dartmouth.edu' with field_list: 'name, uid, did'
  #   When performing a find with look_for: 'bad name' and one: 'true'
  #   Then returns a 'nil' result
  #   And the connection should be closed


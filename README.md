# net-dnd

Net::DND is a Ruby library for performing user finding (aka. lookup) operations on a Dartmouth Name Directory (DND) server. Inspired by the net-ssh library, net-dnd uses a familiar block construct for starting and interacting with a DND session/connection.

Within the block you can submit various find commands and get back zero, one or more 'hits', in the form of Net::DND::Profile instances. Each Profile instance will contain accessors for the fields that were used to seed the DND server connection.

## Installation

    $ sudo gem intall net-dnd

## Basic Usage

Opening a connection to the main Dartmouth College DND server, requesting the return of name and email address fields, for Profiles matching the name `Smith`:

```ruby
profiles = nil
Net::DND.start('dnd.dartmouth.edu', %w(name email)) do |dnd|
  profiles = dnd.find('Smith')
end
puts profiles[0].name, profiles[0].email
```


module Net
  module DND

    # These classes are used to provide good class names to the various errors that might
    # be raised during a Net::DND session. All are based off of of Ruby's standard
    # RuntimeError class.
    class Error < RuntimeError; end

    class FieldNotFound < Net::DND::Error; end

    class FieldLineInvalid < Net::DND::Error; end

    class FieldAccessDenied < Net::DND::Error; end

    class ConnectionError < Net::DND::Error; end

    class ConnectionClosed < Net::DND::Error; end

    class InvalidReponse < Net::DND::Error; end

  end
end

module Net ; module DND

  class Error < RuntimeError; end

  class FieldNotFound < Net::DND::Error; end

  class FieldLineInvalid < Net::DND::Error; end

  class FieldAccessDenied < Net::DND::Error; end

  class ConnectionError < Net::DND::Error; end

  class ConnectionClosed < Net::DND::Error; end

  class InvalidReponse < Net::DND::Error; end

end ; end
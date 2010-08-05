require 'date'

module Net
  module DND

    # Set of methods that are conditionally added to the Profile class, when the "expires" field
    # has been specified.
    module Expires

      def expires_on
        @expires_date ||= Date.parse(expires) rescue nil
      end

      def expire_days
        (expires_on - Date.today).to_i rescue nil
      end

      def expired?
        expire_days.nil? and return false
        expire_days < 1 ? true : false
      end

    end
  end
end
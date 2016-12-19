module Doorkeeper
  module OAuth
    class ErrorResponse
      def body
        {
          errors: [{
            title: name.titleize,
            detail: description,
            state: state
          }.reject { |_, v| v.blank? }]
        }
      end
    end
  end
end

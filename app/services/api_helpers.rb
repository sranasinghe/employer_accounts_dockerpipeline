module APIHelpers
  extend Grape::API::Helpers
  def raise_not_found
    error!(
      {
        errors: [{
          title: 'Not Found',
          detail: 'The requested resource does not exist'
        }]
      }, 404
    )
  end

  def raise_system_error
    error!(
      {
        errors: [{
          title: 'Server Error',
          detail: 'An internal error occurred'
        }]
      }, 500
    )
  end

  def raise_unauthorized(message)
    error!(
      {
        errors: [{
          title: 'Unauthorized',
          detail: message.to_s
        }]
      }, 401
    )
  end

  def raise_bad_request(messages)
    if messages.is_a? Hash
      format_bad_request_hash(messages)
    else
      format_bad_request_string(messages)
    end
  end

  def format_bad_request_hash(messages)
    error!(
      {
        errors: messages.map do |k, v|
          {
            title: 'Invalid Attribute',
            detail: "#{k.to_s.titleize} #{v.join(', ')}"
          }
        end
      }, 400
    )
  end

  def format_bad_request_string(messages)
    error!(
      {
        errors: messages.split(',').map do |message|
          {
            title: 'Invalid Attribute',
            detail: message.strip.to_s
          }
        end
      }, 400
    )
  end
end

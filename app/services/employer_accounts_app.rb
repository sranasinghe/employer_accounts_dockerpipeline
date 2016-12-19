require 'grape-swagger'
require 'doorkeeper/grape/helpers'

class EmployerAccountsApp < Grape::API
  format :json
  content_type :json, 'application/json; charset=utf-8'
  helpers APIHelpers
  helpers Doorkeeper::Grape::Helpers

  helpers do
    def doorkeeper_render_error_with(error)
      status_code = case error.status
                    when :unauthorized
                      401
                    when :forbidden
                      403
                    end

      GrapeLogger.logger.error(
        "#{error.class}: #{error.name.to_s.titleize} - #{error.description}"
      )

      error!(
        {
          errors: [{
            title: error.name.to_s.titleize.to_s,
            detail: error.description.to_s
          }]
        }, status_code, error.headers
      )
    end
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    GrapeLogger.logger.error(
      "#{e.class.name}: #{e.message}}"
    )
    raise_bad_request(e.message)
  end

  # Note: This has to be defined before the mount calls or it won't apply to those routes
  rescue_from :all do |e|
    GrapeLogger.logger.error(
      "Handled Exception: #{e.class.name}, Message: #{e.inspect}\n#{e.backtrace.join("\n")}"
    )
    raise_system_error
  end

  rescue_from Faraday::ConnectionFailed do |e|
    if e.message.include? 'Unknown Status'
      error!(
        {
          errors: [{
            title: 'Contract Error',
            detail: 'No match from contract with provided params'
          }]
        }, 500
      )
    else
      raise_system_error
    end
  end

  mount Endpoint::Healthcheck
  mount Endpoint::Members
  mount Endpoint::Oauth

  add_swagger_documentation \
    mount_path: 'swagger',
    hide_format: true,
    hide_documentation_path: true,
    info: {
      title: 'Employer Accounts',
      description: 'App that handles registration and login'
    }

  # *************************** DO NOT ADD ROUTES BELOW THIS LINE ************************
  # This is the wildcard catch all route. Nothing after this will be processed
  desc '404'
  route :any, '*path' do
    raise_not_found
  end
end

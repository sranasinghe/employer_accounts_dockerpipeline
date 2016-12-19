module Endpoint
  class Healthcheck < Grape::API
    helpers APIHelpers
    resource :healthcheck do
      desc 'Healthcheck',
           success: Entities::Healthcheck
      get '/' do
        begin
          ActiveRecord::Base.connection.active? # ActiveRecord::Base.connection will raise if can't connect
          present 200, with: Entities::Healthcheck
        rescue StandardError => err
          Rails.logger.error(err.message)
          raise_system_error
        end
      end
    end
  end
end

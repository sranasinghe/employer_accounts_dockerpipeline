# This is purely for Swagger UI documentation
module Endpoint
  class Oauth < Grape::API
    helpers APIHelpers

    resources :oauth do
      desc 'Requires for an access token'
      params do
        requires :grant_type,
                 type: String,
                 documentation: { in: 'body' }
        requires :username,
                 type: String,
                 documentation: { in: 'body' }
        requires :password,
                 type: String,
                 documentation: { in: 'body' }
      end

      post :token do
      end
    end

    add_swagger_documentation mount_path: 'oauth/swagger_doc',
                              api_version: '',
                              format: :json,
                              hide_format: true,
                              hide_documentation_path: true
  end
end

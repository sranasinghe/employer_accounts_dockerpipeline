Airbrake.configure do |config|
  config.api_key = '1ec2d379fdf83dcd3782881e19f7f91e'
  config.host    = 'errbit.wellmatchhealth.com'
  config.port    = 443
  config.secure  = config.port == 443
  config.environment_name = Rails.env.to_s
  config.params_filters.concat %w(member_id subscriber_id password email first_name last_name date_of_birth)
end

class LogMiddleware
  attr_reader :app, :env, :request, :logger, :headers

  def initialize(app)
    @app = app
    @logger = Rails.logger
  end

  def call(env)
    @env = env
    @request = Rack::Request.new env
    @headers = extract_headers
    logger.info "[api] Requested: #{request_log_data.to_json}\n"
    status, headers, body = @app.call(env)
    logger.debug "[api] Response: status[#{status}] -- #{get_body(body)}" if env['HTTP_DEBUG']
    [status, headers, body]
  end

  private

  def get_body(body)
    Array(body).first
  end

  def extract_headers
    env.select { |k, _v| k.start_with? 'HTTP_' }
  end

  def request_log_data
    request_data = {
      remote_addr:  request.ip,
      method:       request.request_method,
      path:         request.path,
      query:        filtered_params,
      body:         request.body.read,
      current_user: current_user,
      headers:      headers
    }
    request_data
  end

  def current_user
    env['api.endpoint'].resource_owner.email
  rescue
    ''
  end

  def filtered_params
    filters = Rails.application.config.filter_parameters
    f = ActionDispatch::Http::ParameterFilter.new filters
    f.filter request.params
  end
end

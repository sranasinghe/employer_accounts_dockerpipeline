desc 'Generates OAuth signature and token for test calls using rest clients'
task :generate_test_oauth_credentials, [:email] => :environment do |_t, args|
  args.with_defaults(email: 'rsalinas@test.com')

  def private_key
    pk_string = File.open(Rails.root.join('test', 'private_keys', 'test_private_key.pem'), 'r').read
    OpenSSL::PKey::RSA.new(pk_string)
  end

  def create_headers(private_key, request_body)
    digest = OpenSSL::Digest::SHA256.new
    signature = private_key.sign(digest, request_body)
    { 'Content-Type' => 'application/json', 'WM_SIGNATURE' => "test:#{Base64.strict_encode64(signature).strip}" }
  end

  # create dummy application
  application = Doorkeeper::Application.create(name: 'Test Credentials', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')

  # get handle to test user
  member = Member.find_by(email: args[:email])

  # generate OAuth Token for test user (bypassing grant-step)
  access_token = application.access_tokens.create(resource_owner_id: member.id)

  # Use token to generate request signature and print
  request_body = { token: access_token.token }

  headers = create_headers(private_key, request_body.to_query)

  # print result of CURL call to the /validate endpoint
  headers_string = headers.map { |k, v| "-H '#{k}: #{v}'" }.join(' ')

  curl_string = <<-eos
    curl --data '#{request_body.to_json}' #{headers_string} -v http://localhost:3000/api/token/verify
  eos

  puts
  puts '===== executing curl of /api/token/verify ======='
  puts
  puts curl_string
  puts

  out = `#{curl_string}`
  puts
  puts '======== output ============='
  puts
  puts JSON.pretty_generate(JSON.parse(out))
  puts

  # delete the dummy app
  application.delete
end

require 'securerandom'

# NOTE: For the time being we're simply signing the JWT using a secret and a
# hash.  This is _not_ cryptographically secure.  Once we introduce signature
# verification (in the API Gateway?), we're going to want to use a keypair and
# either RSA or ECDSA to sign the JWT

raise 'Missing JWT_SECRET for Dookeeper in /config/initializers/doorkeeper_jwt.rb' unless ENV['JWT_SECRET']

Doorkeeper::JWT.configure do
  token_payload do |opts|
    member = Member.find(opts[:resource_owner_id])
    iat = Time.now.to_i
    sid = SecureRandom.uuid

    {
      iat: iat,
      jti: Digest::MD5.hexdigest(sid),
      exp: iat + (30 * 24 * 60 * 60),
      uuid: member.id
    }
  end

  secret_key ENV['JWT_SECRET']

  encryption_method :hs512
end

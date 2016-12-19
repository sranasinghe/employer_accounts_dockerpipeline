require 'test_helper'

describe 'API Integration Test' do
  let(:member_attrs) do
    {
      id: 1,
      member_id: 'w111111111',
      date_of_birth: '1987-04-27',
      email: 'test@user.com',
      first_name: 'john',
      last_name: 'doe',
      password: 'Asfasdfsdaf1$'
    }
  end

  before do
    stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
      .to_return(status: 200, body: { coverage_status: { active: true } }.to_json, headers: {})
  end

  describe 'retrieve member data' do
    let(:member) do
      Member.create({ password: 'test_password', password_digest: BCrypt::Password.create('test_password') }.merge(member_attrs))
    end

    let(:token_payload) do
      {
        grant_type: 'password',
        username: 'test@user.com',
        password: 'test_password'
      }
    end

    before do
      member
    end

    describe 'POST /oauth/token returns a JSON payload' do
      before do
        post '/oauth/token', token_payload
      end

      let(:payload) { JSON.parse(@response.body) }

      it { payload.wont_be_nil }

      Member.stubs(:active_coverage?).returns(true) do
        describe ':access_token' do
          let(:access_token) { payload['access_token'] }

          it { access_token.wont_be_nil }

          describe 'in the format of a JWT' do
            it 'should have 3 parts' do
              access_token.split('.').count.must_equal 3
            end

            describe 'once decoded' do
              let(:decoded_token) { JWT.decode(access_token, nil, false) }
              let(:decoded_payload) { decoded_token[0] }
              let(:decoded_metadata) { decoded_token[1] }

              it { decoded_token.class.must_equal Array }

              it { decoded_payload['jti'].wont_be_nil }
              it { decoded_payload['iat'].wont_be_nil }
              it { decoded_payload['exp'].wont_be_nil }
              it { Time.at(decoded_payload['exp']).must_be_close_to 30.days.from_now, 10 }
              it { decoded_metadata['typ'].must_equal 'JWT' }
              it { decoded_metadata['alg'].must_equal 'HS512' }
              it 'should include member id' do
                decoded_payload['uuid'].must_equal member.id
              end
            end
          end

          describe 'Bad login request' do
            it 'fails for bad username' do
              token_payload[:username] = 'BadUsername'
              post '/oauth/token', token_payload
              @response.status.must_equal 401
              JSON.parse(@response.body).must_equal('errors' => [{ 'title' => 'Unauthorized', 'detail' => 'Username or password is invalid' }])
            end

            it 'fails for bad password' do
              token_payload[:password] = 'BadPassword'
              post '/oauth/token', token_payload
              @response.status.must_equal 401
              JSON.parse(@response.body).must_equal('errors' => [{ 'title' => 'Unauthorized', 'detail' => 'Username or password is invalid' }])
            end
          end
        end

        describe 'Coverage status request during login' do
          before do
            stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
              .to_return(status: 200, body: { coverage_status: { active: false } }.to_json, headers: {})
          end
          it 'fails if inactive' do
            post '/oauth/token', token_payload
            @response.status.must_equal 401
            JSON.parse(@response.body).must_equal('errors' => [{ 'title' => 'Coverage Status', 'detail' => 'Coverage not found for member' }])
          end
        end
      end

      Member.stubs(:active_coverage?).returns(true) do
        describe 'GET /api/members/me return member info for a valid oAuth token' do
          it 'returns the correct member info for the valid oAuth token' do
            post '/oauth/token', token_payload

            token = JSON.parse(@response.body)['access_token']

            Member.stub(:find_by_email, member) do
              get '/api/members/me', {}, authorization: "Bearer #{token}", accept: 'application/json'
              response = JSON.parse(@response.body)

              relevant_attrs = member_attrs.except(:password)

              # NOTE that `digest` is not part of `member_attrs` as it is a method
              # on the Member model
              required_keys = relevant_attrs.merge(digest: '123456').keys.map(&:to_s)

              response.keys.all? { |k| required_keys.must_include k }

              relevant_attrs.keys.all? do |k|
                # The ID is a random UUID, so just make sure it is the length of a
                # UUID
                if k == :id
                  response[k.to_s].length.must_equal 36
                else
                  response[k.to_s].must_equal member_attrs[k] unless k == :id
                end
              end
            end
          end
        end
      end

      describe 'GET /api/members/me fails with an invalid oAuth token' do
        it 'returns a 401 with error message' do
          token = 'invalid token'
          get '/api/members/me', {}, authorization: "Bearer #{token}", accept: 'application/json'
          @response.status.must_equal 401
        end
        it 'returns a formatted error message' do
          token = 'invalid token'
          get '/api/members/me', {}, authorization: "Bearer #{token}", accept: 'application/json'
          JSON.parse(@response.body).must_equal('errors' => [{ 'title' => 'Invalid Token', 'detail' => 'The access token is invalid' }])
        end
      end
    end
  end
end

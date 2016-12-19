require_relative '../test_helper'

class Endpoint::MembersTest < Minitest::Spec
  include Rack::Test::Methods

  def app
    Endpoint::Members
  end

  let(:member_json) do
    {
      member:
      {
        id: 1,
        member_id: 'W123456789',
        first_name: 'Jon',
        last_name: 'Snow',
        date_of_birth: '19730604',
        email: 'got@test.com',
        password: 'Password1$'
      }
    }
  end

  let(:active_coverage) do
    {
      'coverage_status' =>
      {
        'active' => true,
        'group_name' => 'THE HOME DEPOT',
        'group_number' => '001500105200004',
        'member_id' => 'W111111'
      },
      'meta' =>
      {
        'timestamp' => DateTime.now.utc
      }
    }
  end

  let(:inactive_coverage) do
    {
      'coverage_status' =>
      {
        'active' => false,
        'group_name' => 'THE HOME DEPOT',
        'group_number' => '001500105200004',
        'member_id' => 'W111111'
      },
      'meta' =>
      {
        'timestamp' => DateTime.now.utc
      }
    }
  end

  describe '/member' do
    context 'success' do
      before do
        stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
          .to_return(status: 200, body: active_coverage.to_json, headers: {})
      end

      it 'creates a member' do
        Member.stubs(:active_coverage?).returns(true) do
          post 'api/members', member_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
          last_response.status.must_equal 201
          last_response.headers['Location'].wont_be_nil
          JSON.parse(last_response.body).keys.must_equal(%w(id member_id first_name last_name date_of_birth email digest))
        end
      end

      it 'returns a 201 for a memberid with extra digits' do
        Member.stubs(:active_coverage?).returns(true) do
          member_json[:member][:member_id] = 'W111111111'
          post '/api/members', member_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
          last_response.status.must_equal 201
        end
      end

      it 'returns a 201 for a memberid with extra whitespace in the middle' do
        Member.stubs(:active_coverage?).returns(true) do
          member_json[:member][:member_id] = 'W12 345  6789'
          post '/api/members', member_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
          last_response.status.must_equal 201
        end
      end
    end

    context 'without active coverage' do
      before do
        stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
          .to_return(status: 200, body: inactive_coverage.to_json, headers: {})
      end

      it 'returns a 401' do
        post '/api/members', member_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
        last_response.status.must_equal 401
        JSON.parse(last_response.body).must_equal(
          'errors' => [{
            'title' => 'Unauthorized',
            'detail' => 'Coverage not found for member'
          }]
        )
      end

      it 'does not create a Member record' do
        post '/api/members', member_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
        assert Member.count == 0
      end
    end

    context 'validations' do
      before do
        stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
          .to_return(status: 200, body: { coverage_status: { active: true } }.to_json, headers: {})
      end

      it 'missing member id' do
        member_json[:member][:member_id] = nil
        post 'api/members', member_json
        last_response.status.must_equal 400
        JSON.parse(last_response.body).must_equal(format_error_message('member[member_id] is empty'))
        last_response.headers['Location'].must_equal nil
      end

      it 'missing first name' do
        member_json[:member][:first_name] = nil
        post 'api/members', member_json
        last_response.status.must_equal 400
        JSON.parse(last_response.body).must_equal(format_error_message('member[first_name] is empty'))
      end

      context 'date of birth' do
        it 'incorrect date format' do
          member_json[:member][:date_of_birth] = 'not a date'
          post 'api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body).must_equal(format_error_message('member[date_of_birth] is invalid'))
        end

        it 'not at least 18 years old' do
          member_json[:member][:date_of_birth] = (Date.today - 18.years + 1.day).to_s
          post 'api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body).must_equal(format_error_message('member[date_of_birth] must be at least 18 years old to register'))
        end

        it 'is at least 18 years old' do
          Member.stubs(:active_coverage?).returns(false) do
            member_json[:member][:date_of_birth] = (Date.today - 18.years).to_s
            post 'api/members', member_json
            last_response.status.must_equal 201
          end
        end
      end

      it 'incorrect email format' do
        member_json[:member][:email] = 'testexample.com'
        post 'api/members', member_json
        last_response.status.must_equal 400
        JSON.parse(last_response.body).must_equal(format_error_message('member[email] is invalid'))
      end

      context 'password' do
        it 'passes with 1 upper, 1 lower, at least 8 length, and 1 digit' do
          member_json[:member][:password] = 'Password1'

          Member.stubs(:active_coverage?).returns(false) do
            post '/api/members', member_json
            last_response.status.must_equal 201
            JSON.parse(last_response.body)['errors'].must_be_nil
          end
        end

        it 'passes with 1 upper, 1 lower, at least 8 length, and 1 special character' do
          member_json[:member][:password] = 'Password$'

          Member.stubs(:active_coverage?).returns(false) do
            post '/api/members', member_json
            last_response.status.must_equal 201
            JSON.parse(last_response.body)['errors'].must_be_nil
          end
        end

        it 'fails validation for password missing' do
          member_json[:member][:password] = ''
          post '/api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body)['errors'].must_include('title' => 'Invalid Attribute', 'detail' => 'member[password] is empty')
        end

        it 'fails validation for password too short' do
          member_json[:member][:password] = '1234567'
          post '/api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body)['errors'].must_include('title' => 'Invalid Attribute', 'detail' => 'member[password] must be at least 8 characters long')
        end

        it 'fails validation for password missing lowercase letter' do
          member_json[:member][:password] = 'NOLOWER'
          post '/api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body)['errors'].must_include('title' => 'Invalid Attribute', 'detail' => 'member[password] must contain at least 1 lowercase letter')
        end

        it 'fails validation for password missing uppercase letter' do
          member_json[:member][:password] = 'noupper'
          post '/api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body)['errors'].must_include('title' => 'Invalid Attribute', 'detail' => 'member[password] must contain at least 1 uppercase letter')
        end

        it 'fails validation for password missing digit or special character' do
          member_json[:member][:password] = 'badpassword'
          post '/api/members', member_json
          last_response.status.must_equal 400
          JSON.parse(last_response.body)['errors'].must_include('title' => 'Invalid Attribute', 'detail' => 'member[password] must contain at least 1 digit or special character')
        end
      end

      it 'fails validation for multiple reasons' do
        member_json[:member][:first_name] = nil
        member_json[:member][:email] = 'testexample.com'
        post '/api/members', member_json
        last_response.status.must_equal 400
        JSON.parse(last_response.body).must_equal('errors' => [{ 'title' => 'Invalid Attribute', 'detail' => 'member[first_name] is empty' }, { 'title' => 'Invalid Attribute', 'detail' => 'member[email] is invalid' }])
      end

      it 'returns a 400 error for duplicate member id, dob, & first name' do
        Member.stubs(:call).returns(false) do
          post '/api/members', member_json
          last_response.status.must_equal 201
          post '/api/members', member_json
          last_response.status.must_equal 400
        end
      end
    end
  end

  describe '/me' do
    let(:member) { Fabricate(:member) }
    let(:token) { Doorkeeper::AccessToken.create! resource_owner_id: member.id }

    context 'happy_path' do
      it 'returns a member json' do
        get 'api/members/me', format: :json, access_token: token.token
        last_response.status.must_equal 200
        body = JSON.parse(last_response.body)
        body['email'].must_equal member.email
      end
    end

    context 'termed_user' do
      let(:termed_member) { Fabricate(:member, termed: true) }
      let(:token) { Doorkeeper::AccessToken.create! resource_owner_id: termed_member.id }

      it 'returns a 401' do
        get 'api/members/me', format: :json, access_token: token.token
        last_response.status.must_equal 401
      end
    end
  end

  def format_error_message(message)
    {
      'errors' => [{
        'title' => 'Invalid Attribute',
        'detail' => message.to_s
      }]
    }
  end
end

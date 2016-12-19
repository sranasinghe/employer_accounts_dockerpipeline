require 'test_helper'

class Endpoint::HealthcheckTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    Endpoint::Healthcheck
  end

  describe 'healthcheck' do
    context 'all is well' do
      it 'should return 200' do
        get '/healthcheck'
        last_response.status.must_equal 200
        last_response.headers['content-type'].must_equal 'application/json; charset=utf-8'
      end
    end

    context 'database is down' do
      it 'should return 500' do
        ActiveRecord::Base.connection.expects(:active?).raises(StandardError.new('ouch!'))
        get '/healthcheck'
        last_response.status.must_equal 500
        JSON.parse(last_response.body).must_equal('errors' => [{ 'title' => 'Server Error', 'detail' => 'An internal error occurred' }])
      end
    end
  end
end

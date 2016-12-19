class CoverageStatus
  attr_accessor :member_id, :member_dob, :first_name

  def self.fetch!(member_id:, member_dob:, first_name:)
    new(member_id: member_id, member_dob: member_dob, first_name: first_name).fetch!
  end

  def initialize(member_id:, member_dob:, first_name:)
    self.member_id = member_id
    self.member_dob = member_dob
    self.first_name = first_name
  end

  def fetch!
    response = fetch_response
    raise StandardError, 'Unable to contact benefits service' if response.status == 500
    coverage_status = Hashie::Mash.new(response.body).coverage_status
    raise StandardError, 'Coverage status malformed' if coverage_status.empty?
    coverage_status
  end

  def member_id=(id)
    @member_id = id.delete(' ')
  end

  private

  def connection
    Faraday.new(url: ENV['BENEFITS_URL']) do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def fetch_response
    connection.post ENV['COVERAGE_STATUS_PATH'], params do |req|
      req.headers['Accept-Version'] = 'v1'
    end
  end

  def params
    { member_id: member_id, member_dob: member_dob, dependent_first_name: first_name }
  end
end

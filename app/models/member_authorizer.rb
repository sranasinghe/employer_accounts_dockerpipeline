class MemberAuthorizer
  attr_reader :member

  def self.from_id(member_id)
    new(Member.find(member_id))
  end

  def initialize(member)
    @member = member
  end

  def status
    termed? ? :unauthorized : :ok
  end

  def json
    termed? ? failure_json : member_json
  end

  # FIXME: this is a Hash, whereas #member_json returns a string.  Given #json,
  # these should probably return the same datatype; so I'm betting we're not
  # doing this right
  def failure_json
    { errors: 'Sorry you are not eligible for WellMatch' }
  end

  def member_json
    member.to_json(only: member_fields, methods: [:digest])
  end

  private

  def member_fields
    %i(member_id
       date_of_birth
       admin
       email
       first_name
       last_name)
  end

  def termed?
    member.termed == true
  end
end

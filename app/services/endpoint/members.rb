module Endpoint
  class Members < Grape::API
    helpers Validators::CustomValidators
    prefix :api

    resource :members do
      desc 'Create Members',
           success: Entities::Member

      params do
        requires :member, type: Hash do
          requires :member_id, type: String, documentation: { in: 'body' }, allow_blank: false
          requires :first_name, type: String, documentation: { in: 'body' }, allow_blank: false
          requires :last_name, type: String, documentation: { in: 'body' }, allow_blank: false
          requires :date_of_birth,
                   type: Date,
                   documentation: { in: 'body' },
                   allow_blank: false,
                   min_age: 18
          requires :email, type: String, documentation: { in: 'body' }, allow_blank: false, regexp: /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          requires :password,
                   type: String,
                   documentation: { in: 'body' },
                   allow_blank: false,
                   one_lower: true,
                   one_upper: true,
                   one_digit_or_special_character: true,
                   min_length: 8
        end
      end

      post '/' do
        @member = Member.new(declared(params)[:member])

        raise_bad_request(@member.errors.messages) unless @member.valid?
        raise_unauthorized('Coverage not found for member') unless @member.active_coverage?

        if @member.save
          header 'location', '/api/members/me'
          present @member, with: Entities::Member
        end
      end

      desc 'Return current resource owner' do
        headers Authorization: {
          description: 'Bearer XYZ',
          required: true,
          default: 'Bearer '
        }
      end

      before do
        doorkeeper_authorize!
      end

      after do
        warm_benefit_cache
      end

      get :me do
        raise_unauthorized('Member termed') if current_resource_owner.status == :unauthorized
        present current_resource_owner.member, with: Entities::Member
      end
    end

    helpers do
      def warm_benefit_cache
        CoverageStatusJob.new.async.perform(current_resource_owner.member)
      end

      def current_resource_owner
        @owner ||= MemberAuthorizer.from_id(doorkeeper_token.resource_owner_id)
      end
    end
  end
end

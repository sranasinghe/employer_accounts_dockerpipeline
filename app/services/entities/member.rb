module Entities
  class Member < Grape::Entity
    expose :id
    expose :member_id
    expose :first_name
    expose :last_name
    expose :date_of_birth
    expose :email
    expose :digest
  end
end

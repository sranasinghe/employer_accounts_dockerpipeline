module Entities
  class Healthcheck < Grape::Entity
    expose :status

    private

    def status
      Time.now.strftime("%l o'clock and all's well!").strip
    end
  end
end

# frozen_string_literal: true

module ApplicationCable
  # Base Connection
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # self.current_user = find_verified_user
      find_verified_user
    end

    private

    def find_verified_user
      # TODO: implement some security here once we build out the admin interface
      # if verified_user = User.find_by(id: cookies.encrypted[:user_id])
      #   verified_user
      # else
      #   reject_unauthorized_connection
      # end
      true
    end
  end
end

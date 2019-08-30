# frozen_string_literal: true

module Api
  module V1
    # Base API Controller
    class BaseApiController < ApplicationController
      respond_to :json

      before_action :doorkeeper_authorize!, except: %i[heartbeat]
      before_action :parse_request, except: %i[me heartbeat]

      def me
        respond_with current_resource_owner
      end

      def heartbeat
        render json: { application: Rails.application.class.name, status: 'ok' }
      end

      private

      # Find the user that owns the access token
      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def authenticate_user_from_token!
        render json: empty_response, status: :unauthorized if @json.nil? || !@json.key?('api_token')

        @user = nil
        User.find_each do |user|
          @user = user if Devise.secure_compare(user.api_token, @json['api_token'])
        end
      end

      def parse_request
        @json = JSON.parse(@request.body.read)
      end

      def empty_response
        [{}].to_json
      end
    end
  end
end

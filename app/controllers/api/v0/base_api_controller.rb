# frozen_string_literal: true

module Api
  module V0
    # Base API Controller
    class BaseApiController < ApplicationController
      respond_to :json

      before_action :check_agent
      before_action :doorkeeper_authorize!, except: %i[heartbeat]
      before_action :parse_request, except: %i[me heartbeat]

      def me
        render json: current_client.to_json
      end

      def heartbeat
        render json: {
          application: Rails.application.class.name.split('::').first,
          status: 'ok'
        }
      end

      private

      # Find the user that owns the access token
      def current_client
        {
          id: doorkeeper_token.application.id,
          uid: doorkeeper_token.application.uid,
          name: doorkeeper_token.application.name,
          redirect_uri: doorkeeper_token.application.redirect_uri,
          created_at: doorkeeper_token.application.created_at.to_s
        }
      end

      def base_response_content
        @application = Rails.application.class.name.split('::').first
        @caller = current_client[:name]
      end

      # Make sure that the user agent matches the caller application/client
      def check_agent
        expecting = "#{current_client[:name]} (#{current_client[:uid]})"
        request.headers.fetch('HTTP_USER_AGENT', nil).downcase == expecting.downcase
      end

      # Parse the body of the incoming request
      def parse_request
        return false unless @request.present? && @request.body.present?

        begin
          @json = JSON.parse(@request.body.read)

        rescue JSON::ParserError => pe
          Rails.logger.error "JSON Parse error on #{@request.path} -> #{pe.message}"
          Rails.logger.error @request.headers
          Rails.logger.error @request.body
          return false
        end
      end

    end
  end
end

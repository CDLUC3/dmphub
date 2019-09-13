# frozen_string_literal: true

module Api
  module V1
    # Base API Controller
    class BaseApiController < ApplicationController
      respond_to :json

      before_action :doorkeeper_authorize!, except: %i[heartbeat]
      before_action :parse_request, except: %i[me heartbeat]

      def me
        render json: current_client.to_json
      end

      def heartbeat
        render json: { application: Rails.application.class.name, status: 'ok' }
      end

      private

      # Find the user that owns the access token
      def current_client
        {
          uid: doorkeeper_token.application.uid,
          name: doorkeeper_token.application.name,
          redirect_uri: doorkeeper_token.application.redirect_uri,
          created_at: doorkeeper_token.application.created_at.to_s
        }
      end

      def parse_request
        return {} unless @request.present? && @request.body.present?
        @json = JSON.parse(@request.body.read)
      end

      def empty_response
        {}
      end

      def error_response(obj)
        { errors: obj.errors.map { |e, m| { "#{e}": m } } }
      end
    end
  end
end

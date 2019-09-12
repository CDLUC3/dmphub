# frozen_string_literal: true

module Api
  module V1
    # Helper methods for generating JSON for the API
    module ApiHelper

      # Default json for ALL models:
      #  'created_at': '2019-09-04 10:13:56 UTC',
      #  'links': [
      #    {'rel': 'self', 'href': 'http://localhost:3000/objects/1'}
      #  ]
      def model_json_base(model:, skip_hateoas: false)
        return unless model.present?
        ret = { 'created': model.created_at.to_s, 'modified': model.updated_at.to_s }
        ret['links'] = [to_hateoas(model: model)] unless skip_hateoas
        ret
      end

      # Generates a Hypermedia As The Engine Of Application State (HATEOAS) link
      # for the model:
      #  'rel':'self',
      #  'href':'http://localhost:3000/models/1'
      def to_hateoas(model:)
        href = "api_v1_#{model.class.name.underscore}_url"
        { 'rel': 'self', 'href': Rails.application.routes.url_helpers.send(href, model.id) }
      end

    end
  end
end

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
      # for the Data Management Plan:
      #  'rel':'self',
      #  'href':'http://localhost:3000/models/1'
      def to_hateoas(model:)
        ident = model.id unless model.is_a?(DataManagementPlan)
        ident = Identifier.where(
          identifiable_id: model.id,
          identifiable_type: 'DataManagementPlan',
          category: 'doi'
        ).first unless ident.present?
        return nil unless ident.present?

        href = Rails.application.routes.url_helpers.send('api_v1_data_management_plan_url', ident.value)

        { 'rel': 'self', 'href': href }
      end

      def response_layout(json:, caller:, source:)
        json.generation_date Time.now.to_s
        json.caller caller
        json.source source
      end

    end
  end
end

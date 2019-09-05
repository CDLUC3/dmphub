# frozen_string_literal: true

# Base Model
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Generates a Hypermedia As The Engine Of Application State (HATEOAS) link
  # for the model:
  #  {'rel':'self','href':'http://localhost:3000/objects/1'}
  def to_hateoas(rel_type = 'self', href = "api_v1_#{self.class.name.underscore}_url")
    href = Rails.application.routes.url_helpers.send(href, id) unless href.start_with?(/https?:/)
    {
      rel: rel_type,
      href: href
    }.to_json
  end

  # Default to_json method that returns the following format:
  #  {
  #    'id': 1,
  #    'created_at': '2019-09-04 10:13:56 UTC',
  #    'links': [
  #      {'rel': 'self', 'href': 'http://localhost:3000/objects/1'}
  #    ]
  #  }
  #
  # Pass in additional fields in the `options` hash that you would like to be a part of the JSON
  #
  # Adding :no_hateoas to the `options` hash will suppress the links section
  #
  # For example if you override this method in your model with:
  #  def to_json(options)
  #    payload = super(%i[name description no_hateoas])
  #    payload['foo'] = 'bar'
  #    payload
  #  end
  #
  # The resulting JSON would look like this:
  #  {
  #    'id': 1,
  #    'created_at': '2019-09-04 10:13:56 UTC',
  #    'name': 'My awesome data management plan',
  #    'description': 'A really great example of a perfect DMP.',
  #    'foo': 'bar'
  #  }
  def to_json(options = [])
    payload = JSON.parse(super(only: %i[created_at]))
    payload['links'] = [JSON.parse(to_hateoas)] if id.present? && !options.include?(:no_hateoas)
    options.each { |attribute| payload[attribute.to_s] = self[attribute] unless %i[no_hateoas full_json].include?(attribute) }
    payload
  end
end

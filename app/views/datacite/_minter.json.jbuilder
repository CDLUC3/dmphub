# frozen_string_literal: true

json.ignore_nil!

json.data do
  json.type 'dois'
  json.attributes do
    json.prefix prefix

    creator = data_management_plan.primary_contact&.person
    if creator.present?
      json.creators do
        json.array! [creator] do |person|
          json.name person.name
        end
      end
    end

    json.titles do
      json.array! [data_management_plan.title] do |title|
        json.title title
      end
    end
    json.publisher provenance
    json.publicationYear Time.now.year

    # TODO: Figure out how to pass this as JSON
    # json.types do
    #  json.array! %w[Text] do |type|
    #    json.resourceTypeGeneral type
    #  end
    # end
  end
end

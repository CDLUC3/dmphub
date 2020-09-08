# frozen_string_literal: true

# Provides methods to handle the affiliation_id hash returned to the controller
# for pages that use the Affiliation selection autocomplete widget
#
# This Concern handles the incoming params from a page that has one of the
# Affiliation Typeahead boxes found in app/views/shared/affiliation_selectors/.
#
# The incoming hash looks like this:
#  {
#    "affiliation_name"=>"Portland State University (PDX)",
#    "affiliation_sources"=>"[
#      \"3E (Belgium) (3e.eu)\",
#      \"etc.\"
#    ]",
#    "affiliation_crosswalk"=>"[
#      {
#        \"id\":1574,
#        \"name\":\"3E (Belgium) (3e.eu)\",
#        \"sort_name\":\"3E\",
#        \"ror\":\"https://ror.org/03d33vh19\"
#      },
#     {
#       "etc."
#    }]",
#    "id"=>"{
#      \"id\":62,
#      \"name\":\"Portland State University (PDX)\",
#      \"sort_name\":\"Portland State University\",
#      \"ror\":\"https://ror.org/00yn2fy02\",
#      \"fundref\":\"https://api.crossref.org/funders/100007083\"
#    }
#  }
#
# The :affiliation_name, :affiliation_sources, :affiliation_crosswalk are all relics of the JS involved in
# handling the request/response from AffiliationsController#search AJAX action that is
# used to search both the local DB and the ROR API as the user types.
#   :affiliation_name = the value the user has types in
#   :affiliation_sources = the pick list of Affiliation names returned by the AffiliationsController#search action
#   :affiliation_crosswalk = all of the info about each Affiliation returned by the AffiliationsController#search action
#                    there is JS that takes the value in :affiliation_name and then sets the :id param
#                    to the matching Affiliation in the :affiliation_crosswalk on form submission
#
# They are typically removed from the incoming params hash prior to doing a :save or :update
# by the :remove_affiliation_selection_params below.
# TODO: Consider adding a JS method that strips those 3 params out prior to form submission
#       since we only need the contents of the :id param here
#
# The contents of :id are then used to either Create or Find the Affiliation from the DB.
# if id: { :id } is present then the Affiliation was one pulled from the DB. If it is not
# present then it is one of the following:
#  if :ror or :fundref are present then it was one retrieved from the ROR API
#  otherwise it is a free text value entered by the user
#
# See the comments on AffiliationsController#search for more info on how the typeaheads work
module AffiliationSelectable
  extend ActiveSupport::Concern

  included do
    protected

    # Finds or creates the selected affiliation and then returns it's id
    def handle_affiliation(attrs:)
      return attrs unless attrs.present? && attrs[:affiliation].present?
      return attrs unless attrs[:affiliation][:id].present?

      affiliation = AffiliationSelection::HashToAffiliationService.to_affiliation(
        hash: attrs[:affiliation], allow_create: true
      )
      # Save the affiliation if it is new
      affiliation.save if affiliation.present? && affiliation.new_record?

      # reattach the affiliation_id but with the Affiliation id instead of the hash
      attrs.delete(:affiliation)
      attrs[:affiliation_id] = affiliation.id
      attrs
    end
  end
end

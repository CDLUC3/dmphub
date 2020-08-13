# frozen_string_literal: true

presenter = Api::V0::ContributorPresenter.new(cdmps: cdmps)

json.contributor presenter.contributors do |contributor|
  json.partial! 'api/v0/rda_common_standard/contributors_show',
                contributor: contributor, rel: 'contributor',
                roles: presenter.contributor_roles[:"#{contributor.id}"]
end

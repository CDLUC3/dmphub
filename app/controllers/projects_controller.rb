# frozen_string_literal: true

# Project Controller
class ProjectsController < ApplicationController
  before_action :authenticate_user!

  # GET /projects/new
  def new
    @project = Project.new(
      awards: [Award.new],
      data_management_plan: DataManagementPlan.new(datasets: [Dataset.new])
    )
  end

  # POST /projects
  def create
    project = Project.from_json(
      provenance: ConversionService.local_provenance,
      json: params_to_rda_json
    )

    project.data_management_plan = DataManagementPlan.new(
      title: project.title,
      datasets: [Dataset.new]
    )

p project.inspect
p project.awards.inspect
p project.data_management_plan.inspect
p project.data_management_plan.datasets.inspect
render json: {message: 'You win!'}
=begin
    if project.save
      begin
        #project.data_management_plan.mint_doi(provenance: ConversionService.local_provenance)

        if project.data_management_plan.doi.present?
          render js: { partial: 'projects/edit',
                       locals: { project: project, message: 'Sweet!' }}
        else
          render json: {
            message: 'Unable to generate a DOI at this time.'
          }, status: :bad_request
        end
      rescue StandardError => e
        render json: {
          message: "Unable to save your changes! #{e.message}"
        }, status: :bad_request
      end
    else
      errs = @project.errors.collect { |er, m| "#{er} - #{m}" }.join(', ')
      render json: {
        message: "Unable to save your changes! #{errs}"
      }, status: :bad_request
    end
=end
  end

  def fundref_autocomplete
    FundrefService.find_by_name(name: autocomplete_params)
  end

  private

  def autocomplete_params
    params.require(:project).permit(:funder_name)
  end

  def project_params
    params.require(:project).permit(:title, :description, :start_on, :end_on,
                                    awards_attributes: [:funder_uri, :funder_name, :status,
                                                        identifiers_attributes: [:category,
                                                                                 :value]])
  end

  def params_to_rda_json
    ConversionService.project_form_params_to_rda(params: project_params)
  end

end

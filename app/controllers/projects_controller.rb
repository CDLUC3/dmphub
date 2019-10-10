# frozen_string_literal: true

# Project Controller
class ProjectsController < ApplicationController
  before_action :authenticate_user!

  # GET /projects/new
  def new
    @project = Project.new(awards: [Award.new])
  end

  # POST /projects
  def create
    @project = Project.from_json(
      provenance: ConversionService.local_provenance,
      json: params_to_rda_json
    )

    @project.data_management_plan = DataManagementPlan.new

p @project.inspect
p @project.awards.first.inspect
p @project.data_management_plan.inspect
p @project.dataset.inspect

    if @project.save
      begin
        #project.data_management_plan.mint_doi(provenance: ConversionService.local_provenance)

        if project.data_management_plan.doi.present?
          redirect_to update_data_management_plan_path(project.data_management_plan,
                      notice: 'Sweet!'
        else
          log_errors(errors: 'Unable to generate a DOI at this time.',
                     action: 'create', params: project_params)
          render json: { error: 'Unable to generate a DOI at this time.' },
                 status: :bad_request
        end
      rescue ActiveModel::Error => e
        log_errors(errors: e.message, action: 'create', params: project_params)
        flash[:alert] = e.message
        render json: { error: "Unable to save your changes! #{e.message}" },
               status: 500
      end
    else
      errs = @project.errors.collect { |er, m| "#{er} - #{m}" }.join(', ')
      log_errors(errors: errs, action: 'create', params: project_params)
      render json: { error: "Unable to save your changes! #{errs}" },
             status: :bad_request
    end
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :start_on, :end_on,
                                    awards: [:funder_uri, :funder_name, :status,
                                             identifiers_attributes: [:category, :value]])
  end

  def params_to_rda_json
    ConversionService.project_form_params_to_rda(params: project_params)
  end

end

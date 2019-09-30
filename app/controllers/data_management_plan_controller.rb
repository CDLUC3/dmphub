# frozen_string_literal: true

# Data Management Plan Controller
class DataManagementPlanController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  # GET /data_management_plan/:id
  def show
    p params[:id]

    doi = Identifier.where(value: params[:id], category: 'doi', identifiable_type: 'DataManagementPlan').first
    render status: 404 if doi.nil?

    @data_management_plan = DataManagementPlan.find(doi.identifiable_id)
  end

  # GET /data_management_plan/new
  def new
    @dmp = DataManagementPlan.new
  end

  # POST /data_management_plans
  def create
    @dmp = DataManagementPlan.from_json(
      provenance: ConversionService.local_provenance,
      json: params_to_rda_json
    )
    if @dmp.save
      begin
        @dmp.mint_doi(provenance: ConversionService.local_provenance)

        if @dmp.mint_doi.present?
          redirect_to dashboard_path, notice: 'Successuly registered your Data Management Plan'
        else
          log_errors(errors: 'Unable to generate a DOI at this time.',
            action: 'create', params: data_management_plan_params)
          flash[:alert] = 'Unable to generate a DOI at this time.'
          render 'new'
        end

      rescue StandardError => se
        log_errors(errors: se.message, action: 'create',
          params: data_management_plan_params)
        flash[:alert] = se.message
        render 'new'
      end
    else
      errs = @dmp.errors.collect { |e, m| "#{e} - #{m}" }.join(', ')
      log_errors(errors: errs, action: 'create', params: dmp)
      flash[:alert] = "Unable to register your DMP! #{errs}"
      render 'new'
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :value)
  end

  def data_management_plan_params
    params.require(:data_management_plan).permit(
      :title, :description, :language, :ethical_issues, :ethical_issues_report,
      :ethical_issues_description, projects_attributes: project_params,
      person_data_management_plans_attributes: person_data_management_plan_params
    )
  end

  def params_to_rda_json
    contact = ConversionService.contact_form_params_to_rda(
      params: contact_params.to_h
    )
    dmp = ConversionService.data_management_plan_form_params_to_rda(
      params: data_management_plan_params.merge(contact_params)
    )
    dmp['contact'] = contact

p dmp.inspect

    dmp
  end

  def log_errors(errors:, action:, params:)
    Rails.logger.error "Unable to #{action} the DMP for User #{current_user.id}!"
    Rails.logger.error errors
    Rails.logger.error "Params: #{params}"
  end

  def person_data_management_plan_params
    [:role, person_attributes: person_params]
  end

  def person_params
    [:name, :email, identifiers_attributes: identifier_params]
  end

  def project_params
    [:title, :description, :start_on, :end_on, awards_attributes: award_params]
  end

  def award_params
    [:funder_uri, :status, identifiers_attributes: identifier_params]
  end

  def identifier_params
    [:category, :value]
  end

end

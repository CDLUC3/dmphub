# frozen_string_literal: true

# Data Management Plan Controller
class DataManagementPlansController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  # GET /dmps/:doi
  def show
    p "MEDIA: #{request.media_type}, "

    val = params[:id].gsub('doi:', Rails.configuration.x.ezid[:doi_prefix])
    doi = Identifier.where(value: val, category: 'doi', identifiable_type: 'DataManagementPlan').first

    if doi.present?
      @dmp = DataManagementPlan.find(doi.identifiable_id)
      @json = render_to_string(template: '/api/v0/data_management_plans/show.json.jbuilder')
      render 'show'
    else
      @dmp = DataManagementPlan.find(params[:id])

      if @dmp.present?
        @json = render_to_string(template: '/api/v0/data_management_plans/show.json.jbuilder')
        render 'show'
      else
        redirect_to root_path, alert: 'No data management plan found for that DOI'
      end
    end
  end

  # GET /data_management_plans/:id/edit
  def edit
    @dmp = DataManagementPlan.find(params[:id])
  end

  # PUT /data_management_plans/:id
  def update
    @dmp = DataManagementPlan.from_json(
      provenance: ConversionService.local_provenance,
      json: params_to_rda_json
    )
    update_primary_contact

    if @dmp.save
      flash[:notice] = 'Your changes have been saved.'
      redirect_to datasets_path
    else
      flash[:alert] = 'Unable to save your changes!'
      render status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :value)
  end

  def data_management_plan_params
    params.require(:data_management_plan).permit(
      :title, :description, :language, :ethical_issues, :ethical_issues_report,
      :ethical_issues_description, person_data_management_plans_attributes: person_data_management_plan_params
    )
  end

  def params_to_rda_json
    contact = ConversionService.contact_form_params_to_rda(
      params: contact_params.to_h
    )
    dmp = ConversionService.data_management_plan_form_params_to_rda(
      params: data_management_plan_params
    )
    dmp['contact'] = contact
    dmp
  end

  def person_data_management_plan_params
    [:role, { person_attributes: person_params }]
  end

  def person_params
    [:name, :email, { identifiers_attributes: identifier_params }]
  end

  def identifier_params
    %i[category value]
  end
end

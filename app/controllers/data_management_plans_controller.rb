# frozen_string_literal: true

# Data Management Plan Controller
class DataManagementPlansController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  # GET /dmps/:doi
  def show
    val = params[:id].gsub('doi:', Rails.configuration.x.ezid[:doi_prefix])
    doi = Identifier.where(value: val, category: 'doi', identifiable_type: 'DataManagementPlan').first
    @source = request.referer

    if doi.present?
      @dmp = DataManagementPlan.find(doi.identifiable_id)
    else
      doi_param_to_dmp
    end

    respond_to do |format|
      if @dmp.present?
        @json = render_to_string(template: '/api/v0/data_management_plans/show.json.jbuilder')

        format.html { render 'show' }
        format.json { render 'api/v0/data_management_plans/show' }
      else
        format.html { redirect_to root_path_location, alert: 'No data management plan found for that DOI' }
        format.json { render '/api/v0/error', status: :not_found }
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

  # Convert the incoming DOI/ARK/URL into a DMP
  def doi_param_to_dmp
    case params[:id][0..3]
    when 'doi:'
      @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('doi:', '')}")
                       .where(category: 'doi', descriptor: 'is_identified_by')
                       .first&.identifiable
    when 'ark:'
      @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('ark:', '')}")
                       .where(category: 'ark', descriptor: 'is_identified_by')
                       .first&.identifiable
    end
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

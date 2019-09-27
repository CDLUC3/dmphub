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
    @dmp.projects << Project.new(awards: [Award.new])

    contact = Person.new(identifiers: [Identifier.new(category: 'orcid')])
    person = Person.new(identifiers: [Identifier.new(category: 'orcid')])
    @dmp.person_data_management_plans << PersonDataManagementPlan.new(
      person: contact, role: 'primary_contact'
    )
    @dmp.person_data_management_plans << PersonDataManagementPlan.new(
      person: person
    )
  end

  # POST /data_management_plans
  def create
    @dmp = DataManagementPlan.new(data_management_plan_params)

    # Attach the primary contact
    contact = Person.new(name: contact_params['name'], email: contact_params['email'])
    contact.identifiers << Identifier.new(category: 'orcid', value: contact_params['value'])
    @dmp.person_data_management_plans << PersonDataManagementPlan.new(person: contact, role: 'primary_contact')

    if @dmp.save
      redirect_to dashboard_path, notice: 'Successuly registered your Data Management Plan'
    else

p @dmp.errors.collect { |e, m| "#{e} - #{m}" }.join(', ')

      flash[:alert] = @dmp.errors.collect { |e, m| "#{e} - #{m}" }.join(', ')
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
      :ethical_issues_description,
      projects_attributes: project_params,
      person_data_management_plans_attributes: person_data_management_plan_params
    )
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
    [:funder_uri, :status]
  end

  def identifier_params
    [:category, :value]
  end

end

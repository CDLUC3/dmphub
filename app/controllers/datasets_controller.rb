# frozen_string_literal: true

# Dataset Controller
class DatasetsController < ApplicationController
  before_action :authenticate_user!

  # GET /data_management_plan/:id/datasets
  def index
    @data_management_plan = DataManagementPlan.where(params[:id]).first || DataManagementPlan.new
    @datasets = @data_management_plan.datasets || [Dataset.new]
  end

  private

  def project_params
    params.require(:dataset).permit(:title, :description, :dataset_type, :sensitive_data,
                                    :personal_data, :publication_date, :language,
                                    :preservation_statement, :data_quality_assurance,
                                    identifiers_attributes: %i[category value],
                                    distribution_attributes: [
                                      :title, :description, :format, :byte_size,
                                      license_attributes: %i[license_uri start_date],
                                      host_attributes: [
                                        :title, :description, :supports_versioning,
                                        :backup_type, :backup_frequency, :storage_type,
                                        :availability, :geo_location,
                                        identifiers_attributes: %i[category value]
                                      ]
                                    ])
  end

  def params_to_rda_json
    ConversionService.dataset_form_params_to_rda(params: dataset_params)
  end
end

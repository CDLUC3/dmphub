# frozen_string_literal: true

# Helper for the Project->DMP->Dataset registration form
module RegistrationFormHelper

  def progress_state(project:, data_management_plan:, datasets:)
    # If the project is a new record
    return 'project' if project.new_record?
    # If the data management plan has not been updated yet
    return 'data_management_plan' if data_management_plan.created_at == data_management_plan.updated_at
    'dataset'
  end

end
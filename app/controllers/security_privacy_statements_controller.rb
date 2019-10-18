# frozen_string_literal: true

class SecurityPrivacyStatementsController < ApplicationController
  before_action :authenticate_user!

  def new
    @statement = SecurityPrivacyStatement.new
  end

  def create
    @statement = SecurityPrivacyStatement.new(statement_params)

    if @statement.save
      flash[:notice] = 'Your changes have been saved.'
      redirect_to new_security_privacy_statement_path
    else
      flash[:alert] = 'Unable to save your changes!'
    end
  end

  private

  def statement_params
    params.require(:security_privacy_statement).permit(:title, :description)
  end
end

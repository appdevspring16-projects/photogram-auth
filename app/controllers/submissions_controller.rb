class SubmissionsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:submit]

  def submit
    render json: params
  end
end

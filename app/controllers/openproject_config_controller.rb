class OpenprojectConfigController < ApplicationController
  prepend_before_action :authenticate_and_authorize!

  def index
    model_index_render(OpenprojectConfig, params)
  end

  def show
    model_show_render(OpenprojectConfig, params)
  end

  def create
    model_create_render(OpenprojectConfig, params)
  end

  def update
    model_update_render(OpenprojectConfig, params)
  end

  def destroy
    model_destroy_render(OpenprojectConfig, params)
  end
end
class Integration::OpenprojectController < ApplicationController
  prepend_before_action :authenticate_and_authorize!

  def verify
    response = ::Openproject.verify(params[:api_token], params[:endpoint], params[:client_id], verify_ssl: params[:verify_ssl])
    render json: {
      result: 'ok',
      response: response,
    }
  rescue => e
    logger.error e

    render json: {
      result: 'failed',
      message: e.message,
    }
  end

  def query
    response = ::Openproject.query(params[:method], params[:filter])
    render json: {
      result: 'ok',
      response: response,
    }
  rescue => e
    logger.error e

    render json: {
      result: 'failed',
      message: e.message,
    }
  end

  def update
    params[:object_ids] ||= []
    ticket = Ticket.find(params[:ticket_id])
    ticket.with_lock do
      authorize!(ticket, :show?)
      ticket.preferences[:openproject] ||= {}
      ticket.preferences[:openproject][:object_ids] = Array(params[:object_ids]).uniq
      ticket.save!
    end

    render json: {
      result: 'ok',
    }
  end
end

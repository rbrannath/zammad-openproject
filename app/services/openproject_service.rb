require 'net/http'
require 'uri'
require 'json'
require 'base64'

class OpenprojectService
  def initialize
    setting = Setting.find_by(name: 'openproject_config')
    raise 'OpenProject configuration not found' unless setting
    Rails.logger.info "Initalize"
    config = setting.state_current

    if config.is_a?(Hash)
      @base_uri = URI(config['value']['endpoint'])
      @username = 'apikey'
      @password = config['value']['api_token']
    else
      raise 'Expected state_current to be a Hash'
    end
  end

  def base_uri()
    return @base_uri
  end

  def post(endpoint, body)
    uri = URI.join(@base_uri.to_s, endpoint)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.basic_auth(@username, @password)
    request.body = body.to_json
    send_request(request)
  end

  def get(endpoint, query_params = {})
    uri = URI.join(@base_uri.to_s, endpoint)
    uri.query = URI.encode_www_form(query_params) unless query_params.empty?
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@username, @password)
    send_request(request)
  end

  def patch(endpoint, body)
    uri = URI.join(@base_uri.to_s, endpoint)
    request = Net::HTTP::Patch.new(uri, 'Content-Type' => 'application/json')
    request.basic_auth(@username, @password)
    request.body = body.to_json
    Rails.logger.info "Request: #{request.to_hash.inspect}"
    send_request(request)
  end

  def delete(endpoint)
    uri = URI.join(@base_uri.to_s, endpoint)
    request = Net::HTTP::Delete.new(uri, 'Content-Type' => 'application/json')
    request.basic_auth(@username, @password)
    Rails.logger.info "Endpoint: #{uri}"
    Rails.logger.info "Request: #{request.to_hash.inspect}"
    send_request(request)
  end

  def send_request(request)
    response = Net::HTTP.start(request.uri.hostname, request.uri.port, use_ssl: request.uri.scheme == 'https') do |http|
      http.request(request)
    end
    Rails.logger.info "Request: #{response}"
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Fehler bei der Kommunikation mit OpenProject: #{response.message}"
      return nil
    end

    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "Fehler bei der Verarbeitung der Anfrage: #{e.message}"
    nil
  end

  def build_work_package_body(ticket, params)
    {
      subject: ticket.subject,
      description: { raw: ticket.description },
    }
  end
end

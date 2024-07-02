require 'net/http'
require 'uri'

module Openproject
  
  def self.verify(api_token, endpoint, client_id = nil, verify_ssl: false)
    Rails.logger.info "Verify config openproject"
    raise 'api_token required' if api_token.blank?
    raise 'endpoint required' if endpoint.blank?

    uri = URI.parse(endpoint)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth('apikey', api_token)

    req_options = {
      use_ssl: uri.scheme == "https",
      verify_mode: verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    raise "Connection to #{endpoint} failed with status #{response.code}" unless response.code.to_i == 200

    JSON.parse(response.body)
  end

  def self.query(method, filter = {})
    setting = Setting.get('openproject_config')
    raise "The required field 'api_token' is missing from the config." if setting[:api_token].blank?
    raise "The required field 'endpoint' is missing from the config." if setting[:endpoint].blank?

    params = { apikey: setting[:api_token] }
    params[:filter] = filter if filter.present?
    _query(method, params, _url_cleanup(setting[:endpoint]), verify_ssl: setting[:verify_ssl])
  end

  def self._query(method, params, url, verify_ssl: false)
    full_url = "#{url}/#{method}"
    result = UserAgent.post(
      full_url,
      params,
      {
        verify_ssl: verify_ssl,
        json: true,
        open_timeout: 6,
        read_timeout: 16,
        log: { facility: 'openproject' }
      }
    )

    raise "Can't fetch objects from #{full_url}: Unable to parse response from server. Invalid JSON response." if !result.success? && result.error =~ %r{JSON::ParserError:.+?\s+unexpected\s+token\s+at\s+'<!DOCTYPE\s+html}i
    raise "Can't fetch objects from #{full_url}: #{result.error}" if !result.success?

    result.data
  end

  def self._url_cleanup(url)
    url.strip!
    raise "Invalid endpoint '#{url}', need to start with http:// or https://" unless url.match?(%r{^http(s|)://}i)

    url.gsub(%r{([^:])//+}, '\\1/')
    url.chomp!('/')
    url
  end
end

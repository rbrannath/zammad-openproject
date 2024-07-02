# module Openproject
#     def self.verify(api_token, endpoint, client_id, verify_ssl: true)
#       # Beispiel Verifizierungslogik
#       response = HTTParty.get("#{endpoint}/api/v3/projects",
#                               headers: { "Authorization" => "Bearer #{api_token}", "Client-ID" => client_id },
#                               verify: verify_ssl)
#       response.parsed_response
#     rescue => e
#       raise "Verification failed: #{e.message}"
#     end
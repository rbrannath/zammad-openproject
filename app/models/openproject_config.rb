class OpenProjectConfig < ApplicationRecord
  validates :base_uri, presence: true
  validates :api_token, presence: true
end

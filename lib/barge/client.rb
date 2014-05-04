require 'faraday'
require 'faraday_middleware'

module Barge
  class Client
    attr_accessor :access_token

    attr_reader :droplet

    DEFAULT_OPTIONS = {}
    DIGITAL_OCEAN_URL = 'https://api.digitalocean.com'
    TIMEOUTS = 10

    def initialize(options = DEFAULT_OPTIONS)
      self.access_token = options.fetch(:access_token, nil)
      yield(self) if block_given?
      fail ArgumentError, 'missing access_token' unless access_token
      initialize_resources
    end

    private

    def initialize_resources
      @droplet = Resource::Droplet.new(faraday)
    end

    def faraday
      @faraday ||= Faraday.new faraday_options do |f|
        f.adapter :net_http
        f.request :url_encoded
        f.response :json

        f.options.open_timeout = TIMEOUTS
        f.options.timeout = TIMEOUTS
      end
    end

    def faraday_options
      {
        headers: { authorization: access_token },
        url: DIGITAL_OCEAN_URL
      }
    end
  end
end

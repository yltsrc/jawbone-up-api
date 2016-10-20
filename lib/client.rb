require 'httparty'

module Jawbone

  class Client

    attr_accessor :token

    API_VERSION = "1.1"
    BASE_URL = "https://jawbone.com/nudge/api/v.1.1"

    include HTTParty

    def initialize(token)
      @token = token
    end

    def band_events(params={})
      get_helper("users/@me/bandevents", params)
    end

    def heart_rates(params={})
      get_helper("users/@me/heartrates", params)
    end

    def goals
      get_helper("users/@me/goals", {})
    end

    def update_goal(params={})
      post_helper("users/@me/goals", params)
    end

    def refresh_token(client_secret)
      post_helper("users/@me/refreshToken", { secret: client_secret })
    end

    def settings
      get_helper("users/@me/settings", {})
    end

    def time_zone
      get_helper("users/@me/timezone", {})
    end

    def trends(params={})
      get_helper("users/@me/trends", params)
    end

    def user
      get_helper("users/@me", {})
    end

    def friends
      get_helper("users/@me/friends", {})
    end

    base_strings = ["body_event", "generic_event", "meal", "mood", "move",
                    "sleep", "workout"]

    base_strings.each do |base|
      index_method_name = base + "s"
      plural = base == "mood" ? base : index_method_name

      define_method index_method_name do |*args|
        get_helper("users/@me/#{plural}", args.first || {})
      end

      # TODO: skip: generic_event
      define_method base do |id|
        get_helper("#{plural}/#{id}", {})
      end

      # TODO: only: move sleep workout
      define_method "#{base}_graph" do |id|
        get_helper("#{plural}/#{id}/image", {})
      end
      define_method "#{base}_ticks" do |id|
        get_helper("#{plural}/#{id}/ticks", {})
      end

      # TODO: skip: move
      define_method "create_#{base}" do |params|
        post_helper("users/@me/#{plural}", params)
      end

      # TODO: skip: body_event, mood, move, spleep
      define_method "update_#{base}" do |id, params|
        post_helper("#{plural}/#{id}/partialUpdate", params)
      end

      # TODO: skip: move
      define_method "delete_#{base}" do |id|
        delete_helper("#{plural}/#{id}")
      end
    end

    def create_webhook(url)
      post_helper("users/@me/pubsub", { webhook: url })
    end

    def delete_webhook
      delete_helper("users/@me/pubsub")
    end

    def disconnect
      delete_helper("users/@me/PartnerAppMembership")
    end

    def self.refresh_token(client_id, app_secret, refresh_token)
      url = 'https://jawbone.com/auth/oauth2/token'
      response = post(url, { body: { client_id: client_id,
                                     client_secret: app_secret,
                                     grant_type: 'refresh_token',
                                     refresh_token: refresh_token } })
      response.parsed_response
    end

    private

    def post_helper(path, params)
      path = "/" + path unless path[0] == '/'
      url = BASE_URL + path
      response = self.class.post url,
        { :headers =>
          { "Authorization" => "Bearer #{token}",
            "Content-Type" => "application/x-www-form-urlencoded" },
          :body => params
        }
      response.parsed_response
    end

    def delete_helper(path)
      path = "/" + path unless path[0] == '/'
      url = BASE_URL + path
      response = self.class.delete url,
        { :headers =>
          { "Authorization" => "Bearer #{token}" }
        }
      response.parsed_response
    end

    def get_helper(path, params={})
      path = "/" + path unless path[0] == '/'
      url = BASE_URL + path
      stringified_params = params.collect do |k, v|
        "#{k}=#{v}"
      end.sort * '&'
      full_url = url + "?" + stringified_params
      response = self.class.get full_url,
        { :headers => { "Authorization" => "Bearer #{token}" } }
      response.parsed_response
    end

  end

end

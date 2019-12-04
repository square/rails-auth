# frozen_string_literal: true

module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    module_function

    # Mark a request as externally authorized. Causes ACL checks to be skipped.
    #
    # @param [Hash] :rack_env Rack environment
    # @param [String] :allowed_by what allowed the request
    #
    def authorized!(rack_env, allowed_by)
      Env.new(rack_env).tap do |env|
        env.authorize(allowed_by)
      end.to_rack
    end

    # Check whether a request has been authorized
    #
    # @param [Hash] :rack_env Rack environment
    #
    def authorized?(rack_env)
      Env.new(rack_env).authorized?
    end

    # Mark what authorized the request in the Rack environment
    #
    # @param [Hash] :rack_env Rack environment
    # @param [String] :allowed_by what allowed this request
    def set_allowed_by(rack_env, allowed_by)
      Env.new(rack_env).tap do |env|
        env.allowed_by = allowed_by
      end.to_rack
    end

    # Read what authorized the request
    #
    # @param [Hash] :rack_env Rack environment
    #
    # @return [String, nil] what authorized the request
    def allowed_by(rack_env)
      Env.new(rack_env).allowed_by
    end

    # Obtain credentials from a Rack environment
    #
    # @param [Hash] :rack_env Rack environment
    #
    def credentials(rack_env)
      Credentials.from_rack_env(rack_env)
    end

    # Add a credential to the Rack environment
    #
    # @param [Hash] :rack_env Rack environment
    # @param [String] :type credential type to add to the environment
    # @param [Object] :credential object to add to the environment
    #
    def add_credential(rack_env, type, credential)
      Env.new(rack_env).tap do |env|
        env.credentials[type] = credential
      end.to_rack
    end
  end
end

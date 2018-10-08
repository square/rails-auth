# frozen_string_literal: true

require "logger"

RSpec.describe Rails::Auth::ACL::Middleware do
  let(:request)     { Rack::MockRequest.env_for("https://www.example.com") }
  let(:app)         { ->(env) { [200, env, "Hello, world!"] } }
  let(:acl)         { instance_double(Rails::Auth::ACL, match: authorized) }
  let(:middleware)  { described_class.new(app, acl: acl) }

  context "authorized" do
    let(:authorized) { true }

    it "allows authorized requests" do
      expect(middleware.call(request)[0]).to eq 200
    end
  end

  context "unauthorized" do
    let(:authorized) { false }

    it "raises Rails::Auth::NotAuthorizedError for unauthorized requests" do
      expect { expect(middleware.call(request)) }.to raise_error(Rails::Auth::NotAuthorizedError)
    end
  end

  context "externally authorized requests" do
    let(:authorized) { false }
    let(:external_middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          allowed_by = "example"
          Rails::Auth.authorized!(env, allowed_by)
          @app.call(env)
        end
      end
    end

    it "allows externally authorized requests" do
      expect(external_middleware.new(middleware).call(request)[0]).to eq 200
    end
  end
end

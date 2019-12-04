# frozen_string_literal: true

RSpec.describe Rails::Auth::Monitor::Middleware do
  let(:request) { Rack::MockRequest.env_for("https://www.example.com") }

  describe "access granted" do
    let(:code) { 200 }
    let(:app)  { ->(env) { [code, env, "Hello, world!"] } }

    it "fires the callback with the env and true" do
      callback_fired = false

      middleware = described_class.new(app, lambda do |env, success|
        callback_fired = true
        expect(env).to be_a Hash
        expect(success).to eq true
      end)

      response = middleware.call(request)
      expect(callback_fired).to eq true
      expect(response.first).to eq code
    end
  end

  describe "access denied" do
    let(:app) { ->(_env) { raise(Rails::Auth::NotAuthorizedError, "not authorized!") } }

    it "renders the error page" do
      callback_fired = false

      middleware = described_class.new(app, lambda do |env, success|
        callback_fired = true
        expect(env).to be_a Hash
        expect(success).to eq false
      end)

      expect { middleware.call(request) }.to raise_error(Rails::Auth::NotAuthorizedError)
      expect(callback_fired).to eq true
    end
  end
end

# frozen_string_literal: true

RSpec.describe Rails::Auth::ErrorPage::Middleware do
  let(:request)    { Rack::MockRequest.env_for("https://www.example.com") }
  let(:error_page) { "<h1> Unauthorized!!! </h1>" }

  subject(:middleware) { described_class.new(app, page_body: error_page) }

  context "unspecified content type" do
    describe "access granted" do
      let(:code) { 200 }
      let(:app)  { ->(env) { [code, env, "Hello, world!"] } }

      it "renders the expected response" do
        response = middleware.call(request)
        expect(response.first).to eq code
      end
    end

    describe "access denied" do
      let(:app) { ->(_env) { raise(Rails::Auth::NotAuthorizedError, "not authorized!") } }

      it "renders the error page" do
        code, _env, body = middleware.call(request)
        expect(code).to eq 403
        expect(body).to eq [error_page]
      end
    end
  end

  context "JSON content type" do
    let(:app)     { ->(_env) { raise(Rails::Auth::NotAuthorizedError, "not authorized!") } }
    let(:message) { { message: "Access denied" }.to_json }

    context "via request path" do
      let(:request) { Rack::MockRequest.env_for("https://www.example.com/foobar.json?x=1&y=2") }

      it "renders a JSON response" do
        code, env, body = middleware.call(request)
        expect(code).to eq 403
        expect(env["Content-Type"]).to eq "application/json"
        expect(body).to eq [message]
      end
    end

    context "via Accept header" do
      it "renders a JSON response" do
        request["HTTP_ACCEPT"] = "application/json"

        code, env, body = middleware.call(request)
        expect(code).to eq 403
        expect(env["Content-Type"]).to eq "application/json"
        expect(body).to eq [message]
      end
    end
  end
end

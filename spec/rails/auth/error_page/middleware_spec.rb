RSpec.describe Rails::Auth::ErrorPage::Middleware do
  let(:request)    { Rack::MockRequest.env_for("https://www.example.com") }
  let(:error_page) { "<h1> Unauthorized!!! </h1>" }

  subject(:middleware) { described_class.new(app, page_body: error_page) }

  context "access granted" do
    let(:code) { 200 }
    let(:app)  { ->(env) { [code, env, "Hello, world!"] } }

    it "renders the expected response" do
      response = middleware.call(request)
      expect(response.first).to eq code
    end
  end

  context "access denied" do
    let(:app) { ->(_env) { raise(Rails::Auth::NotAuthorizedError, "not authorized!") } }

    it "renders the error page" do
      code, _env, body = middleware.call(request)
      expect(code).to eq 403
      expect(body).to eq [error_page]
    end
  end
end

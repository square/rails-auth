# frozen_string_literal: true

RSpec.describe Rails::Auth::ControllerMethods do
  let(:controller_class) do
    Class.new do
      attr_reader :request

      def initialize(env)
        @request = OpenStruct.new(env: env)
      end

      include Rails::Auth::ControllerMethods
    end
  end

  describe "#credentials" do
    let(:example_credential_type)  { "x509" }
    let(:example_credential_value) { instance_double(Rails::Auth::X509::Certificate) }

    let(:example_env) { Rails::Auth.add_credential({}, example_credential_type, example_credential_value) }
    let(:example_controller) { controller_class.new(example_env) }

    it "extracts credentials from the Rack environment" do
      expect(example_controller.credentials[example_credential_type.to_sym]).to eq example_credential_value
    end
  end
end

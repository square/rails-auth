RSpec.describe Rails::Auth::ACL::Resource do
  let(:example_method) { "GET" }
  let(:another_method) { "POST" }
  let(:example_path)   { "/foobar" }
  let(:another_path)   { "/baz" }

  let(:example_options) do
    {
      "method" => example_method,
      "path"   => example_path
    }
  end

  let(:example_predicates) { { "example" => double(:predicate, match: predicate_matches) } }
  let(:example_resource)   { described_class.new(example_options, example_predicates) }
  let(:example_env)        { env_for(example_method, example_path) }

  describe "#initialize" do
    it "initializes with a method and a path" do
      resource = described_class.new(
        {
          "method" => example_method,
          "path"   => example_path
        },
        {}
      )

      expect(resource.http_methods).to eq [example_method]
    end

    it "accepts ALL as a specifier for all HTTP methods" do
      resource = described_class.new(
        {
          "method" => "ALL",
          "path"   => example_path
        },
        {}
      )

      expect(resource.http_methods).to eq nil
    end

    context "errors" do
      let(:invalid_method) { "DERP" }

      it "raises ParseError for invalid HTTP methods" do
        expect do
          described_class.new(
            {
              "method" => invalid_method,
              "path"   => example_path
            },
            {}
          )
        end.to raise_error(Rails::Auth::ParseError)
      end
    end
  end

  describe "#match" do
    context "with matching predicates and method/path" do
      let(:predicate_matches) { true }

      it "matches against a valid resource" do
        expect(example_resource.match(example_env)).to eq true
      end
    end

    context "without matching predicates" do
      let(:predicate_matches) { false }

      it "doesn't match against a valid resource" do
        expect(example_resource.match(example_env)).to eq false
      end
    end

    context "without a method/path match" do
      let(:predicate_matches) { true }

      it "doesn't match" do
        env = env_for(another_method, example_path)
        expect(example_resource.match(env)).to eq false
      end
    end
  end

  describe "#match_method_and_path" do
    let(:predicate_matches) { false }

    it "matches against all methods if specified" do
      resource = described_class.new(example_options.merge("method" => "ALL"), example_predicates)
      expect(resource.match_method_and_path(example_env)).to eq true
    end

    it "doesn't match if the method mismatches" do
      env = env_for(another_method, example_path)
      expect(example_resource.match_method_and_path(env)).to eq false
    end

    it "doesn't match if the path mismatches" do
      env = env_for(example_method, another_path)
      expect(example_resource.match_method_and_path(env)).to eq false
    end
  end
end

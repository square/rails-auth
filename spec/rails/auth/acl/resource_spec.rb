# frozen_string_literal: true

RSpec.describe Rails::Auth::ACL::Resource do
  let(:example_method) { "GET" }
  let(:another_method) { "POST" }
  let(:example_path)   { "/foobar" }
  let(:another_path)   { "/baz" }

  let(:example_matchers) { { "example" => double(:matcher, match: matcher_matches) } }
  let(:example_resource)   { described_class.new(example_options, example_matchers) }
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

      expect(resource.http_methods).to eq Rails::Auth::ACL::Resource::HTTP_METHODS
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

  context "without a host specified" do
    let(:example_options) do
      {
        "method" => example_method,
        "path"   => example_path
      }
    end

    describe "#match" do
      context "with matching matchers and method/path" do
        let(:matcher_matches) { true }

        it "matches against a valid resource" do
          expect(example_resource.match(example_env)).to eq "example"
        end
      end

      context "without matching matchers" do
        let(:matcher_matches) { false }

        it "doesn't match against a valid resource" do
          expect(example_resource.match(example_env)).to eq nil
        end
      end

      context "without a method/path match" do
        let(:matcher_matches) { true }

        it "doesn't match" do
          env = env_for(another_method, example_path)
          expect(example_resource.match(env)).to eq nil
        end
      end
    end

    describe "#match!" do
      let(:matcher_matches) { false }

      it "matches against all methods if specified" do
        resource = described_class.new(example_options.merge("method" => "ALL"), example_matchers)
        expect(resource.match!(example_env)).to eq true
      end

      it "doesn't match if the method mismatches" do
        env = env_for(another_method, example_path)
        expect(example_resource.match!(env)).to eq false
      end

      it "doesn't match if the path mismatches" do
        env = env_for(example_method, another_path)
        expect(example_resource.match!(env)).to eq false
      end
    end
  end

  context "with a host specified" do
    let(:example_host) { "www.example.com" }
    let(:bogus_host)   { "www.trololol.com" }
    let(:matcher_matches) { true }

    let(:example_options) do
      {
        "method" => example_method,
        "path"   => example_path,
        "host"   => example_host
      }
    end

    describe "#match" do
      it "matches if the host matches" do
        example_env["HTTP_HOST"] = example_host
        expect(example_resource.match(example_env)).to eq "example"
      end

      it "doesn't match if the host mismatches" do
        example_env["HTTP_HOST"] = bogus_host
        expect(example_resource.match(example_env)).to eq nil
      end
    end

    describe "#match!" do
      it "matches if the host matches" do
        example_env["HTTP_HOST"] = example_host
        expect(example_resource.match(example_env)).to eq "example"
      end

      it "doesn't match if the host mismatches" do
        example_env["HTTP_HOST"] = bogus_host
        expect(example_resource.match(example_env)).to eq nil
      end
    end
  end
end

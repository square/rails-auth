# frozen_string_literal: true

RSpec.describe Rails::Auth::ACL::Matchers::AllowAll do
  let(:matcher)     { described_class.new(enabled) }
  let(:example_env) { env_for(:get, "/") }

  describe "#initialize" do
    it "raises if given nil" do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it "raises if given a non-boolean" do
      expect { described_class.new(42) }.to raise_error(ArgumentError)
    end
  end

  describe "#match" do
    context "enabled" do
      let(:enabled) { true }

      it "allows all requests" do
        expect(matcher.match(example_env)).to eq true
      end
    end

    context "disabled" do
      let(:enabled) { false }

      it "rejects all requests" do
        expect(matcher.match(example_env)).to eq false
      end
    end
  end

  it "knows its attributes" do
    matcher = described_class.new(true)
    expect(matcher.attributes).to eq true
  end
end

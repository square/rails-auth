# A strawman matcher for claims-based credentials for use in tests
# frozen_string_literal: true

class ClaimsMatcher
  def initialize(options)
    @options = options
  end

  def match(_env)
    # Pretend like we have a claim to be in the "example" group
    @options["group"] == "example"
  end
end

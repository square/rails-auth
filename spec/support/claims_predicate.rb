# An additional predicate class for tests
class ClaimsPredicate
  def initialize(options)
    @options = options
  end

  def match(_env)
    # Pretend like our principal is in the "example" group
    @options["group"] == "example"
  end
end

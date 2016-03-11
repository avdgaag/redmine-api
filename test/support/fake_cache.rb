require 'delegate'

class FakeCache < DelegateClass(Hash)
  def initialize
    super({})
  end

  def transaction
    yield
  end
end

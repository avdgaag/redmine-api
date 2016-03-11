class FakeHttp
  attr_reader :requests

  def initialize
    @requests = []
    @next_response = :fake_http_response
  end

  def respond_with(response)
    @next_response = response
  end

  def request(req)
    @requests << req
    @next_response
  end
end

# frozen_string_literal: true

require "test_helper"
require "net/http"
require "json"

class WebhookTest < Minitest::Test
  def setup
    @port = 19876 + rand(100)
    @agent = MockAgent.new
    config = { "channels" => { "webhook" => { "port" => @port } } }

    ENV.delete("HERMITCLAW_WEBHOOK_TOKEN")
    @webhook = HermitClaw::Channels::Webhook.new(agent: @agent, config: config)
    @webhook.start
    sleep 0.3 # wait for server to start
  end

  def teardown
    @webhook.stop
  end

  def test_health_check
    res = get("/health")

    assert_equal "200", res.code
    body = JSON.parse(res.body)
    assert_equal "ok", body["status"]
  end

  def test_successful_response
    res = post("/webhook", { user_id: "user1", message: "hello" })

    assert_equal "200", res.code
    body = JSON.parse(res.body)
    assert_equal "mock response to: hello", body["response"]
    assert_equal "user1", body["user_id"]
  end

  def test_missing_message
    res = post("/webhook", { user_id: "user1" })

    assert_equal "400", res.code
    body = JSON.parse(res.body)
    assert_equal "Missing 'message' field", body["error"]
  end

  def test_invalid_json
    uri = URI("http://127.0.0.1:#{@port}/webhook")
    req = Net::HTTP::Post.new(uri)
    req.body = "not json"
    req.content_type = "application/json"
    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    assert_equal "400", res.code
  end

  def test_get_method_not_allowed
    res = get("/webhook")

    assert_equal "405", res.code
  end

  def test_auth_required_when_token_set
    @webhook.stop
    ENV["HERMITCLAW_WEBHOOK_TOKEN"] = "secret123"
    config = { "channels" => { "webhook" => { "port" => @port } } }
    @webhook = HermitClaw::Channels::Webhook.new(agent: @agent, config: config)
    @webhook.start
    sleep 0.3

    # Without token
    res = post("/webhook", { user_id: "user1", message: "hello" })
    assert_equal "401", res.code

    # With correct token
    res = post("/webhook", { user_id: "user1", message: "hello" },
               headers: { "Authorization" => "Bearer secret123" })
    assert_equal "200", res.code
  ensure
    ENV.delete("HERMITCLAW_WEBHOOK_TOKEN")
  end

  def test_metadata_passthrough
    res = post("/webhook", {
      user_id: "user1",
      message: "hello",
      metadata: { source: "bootcamp", comment_id: 42 }
    })

    body = JSON.parse(res.body)
    assert_equal "bootcamp", body["metadata"]["source"]
    assert_equal 42, body["metadata"]["comment_id"]
  end

  private

  def get(path)
    uri = URI("http://127.0.0.1:#{@port}#{path}")
    Net::HTTP.get_response(uri)
  end

  def post(path, body, headers: {})
    uri = URI("http://127.0.0.1:#{@port}#{path}")
    req = Net::HTTP::Post.new(uri)
    req.body = body.to_json
    req.content_type = "application/json"
    headers.each { |k, v| req[k] = v }
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  end

  class MockAgent
    def respond(user_id:, message:)
      "mock response to: #{message}"
    end
  end
end

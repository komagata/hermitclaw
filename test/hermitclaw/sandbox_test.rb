# frozen_string_literal: true

require "test_helper"

class SandboxTest < Minitest::Test
  def test_process_sandbox_available
    sandbox = HermitClaw::Sandbox::Process.new

    assert sandbox.available?
  end

  def test_process_sandbox_executes_command
    sandbox = HermitClaw::Sandbox::Process.new

    result = sandbox.execute(command: "echo hello")

    assert result[:success]
    assert_equal "hello\n", result[:stdout]
    assert_equal 0, result[:exit_code]
  end

  def test_process_sandbox_captures_stderr
    sandbox = HermitClaw::Sandbox::Process.new

    result = sandbox.execute(command: "echo error >&2")

    assert result[:success]
    assert_equal "error\n", result[:stderr]
  end

  def test_process_sandbox_handles_failure
    sandbox = HermitClaw::Sandbox::Process.new

    result = sandbox.execute(command: "exit 1")

    refute result[:success]
    assert_equal 1, result[:exit_code]
  end

  def test_process_sandbox_timeout
    sandbox = HermitClaw::Sandbox::Process.new

    result = sandbox.execute(command: "sleep 10", timeout: 1)

    refute result[:success]
    assert_includes result[:stderr], "timed out"
  end

  def test_process_sandbox_with_env
    sandbox = HermitClaw::Sandbox::Process.new

    result = sandbox.execute(command: "echo $TEST_VAR", env: { "TEST_VAR" => "hello" })

    assert result[:success]
    assert_equal "hello\n", result[:stdout]
  end

  def test_factory_creates_process_sandbox
    sandbox = HermitClaw::Sandbox.create("backend" => "process")

    assert_instance_of HermitClaw::Sandbox::Process, sandbox
  end

  def test_factory_defaults_to_process
    sandbox = HermitClaw::Sandbox.create({})

    assert_instance_of HermitClaw::Sandbox::Process, sandbox
  end

  def test_docker_sandbox_flags
    # Just verify Docker sandbox can be instantiated
    sandbox = HermitClaw::Sandbox::Docker.new(config: {
      "memory_limit" => "64m",
      "cpu_limit" => "0.25",
      "network" => "none"
    })

    assert_instance_of HermitClaw::Sandbox::Docker, sandbox
  end
end

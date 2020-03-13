# frozen_string_literal: true

require "spec_helper"
require "cgi"

RSpec.describe Gemstash::GemSource do
  let(:app) { double }
  let(:middleware) { Gemstash::GemSource::RackMiddleware.new(app) }

  context "using private gem source" do
    let(:env) do
      {
        "gemstash.env" => Gemstash::Env.current,
        "REQUEST_URI" => "/private/some/path?arg=abc",
        "PATH_INFO" => "/private/some/path"
      }
    end

    let(:result) { double }

    it "sets the source to PrivateSource and rewrites the path" do
      expect(app).to receive(:call).with(env).and_return(result)
      expect(middleware.call(env)).to eq(result)
      expect(env["gemstash.gem_source"]).to eq(Gemstash::GemSource::PrivateSource)
      expect(env["REQUEST_URI"]).to eq("/some/path?arg=abc")
      expect(env["PATH_INFO"]).to eq("/some/path")
      expect(the_log).to include("Rewriting '/private/some/path?arg=abc' to '/some/path?arg=abc'")
    end
  end

  context "using a custom upstream" do
    let(:env) do
      {
        "gemstash.env" => Gemstash::Env.current,
        "REQUEST_URI" => "/upstream/#{escaped_upstream_url}/some/path?arg=abc",
        "PATH_INFO" => "/upstream/#{escaped_upstream_url}/some/path"
      }
    end

    let(:upstream_url) { "https://some.gemsite.com" }
    let(:escaped_upstream_url) { CGI.escape(upstream_url) }
    let(:result) { double }

    it "sets the source to UpstreamSource and rewrites the path" do
      expect(app).to receive(:call).with(env).and_return(result)
      expect(middleware.call(env)).to eq(result)
      expect(env["gemstash.gem_source"]).to eq(Gemstash::GemSource::UpstreamSource)
      expect(env["REQUEST_URI"]).to eq("/some/path?arg=abc")
      expect(env["PATH_INFO"]).to eq("/some/path")
      expect(the_log).to include("Rewriting '/upstream/#{escaped_upstream_url}\
/some/path?arg=abc' to '/some/path?arg=abc'")
    end
  end

  context "using an upstream defined in a header" do
    let(:env) do
      {
        "gemstash.env" => Gemstash::Env.current,
        "REQUEST_URI" => "/some/path?arg=abc",
        "PATH_INFO" => "/some/path",
        "HTTP_X_GEMFILE_SOURCE" => upstream_url
      }
    end

    let(:upstream_url) { "https://some.gemsite.com" }
    let(:result) { double }

    it "sets the source to RubygemsSource" do
      expect(app).to receive(:call).with(env).and_return(result)
      expect(middleware.call(env)).to eq(result)
      expect(env["gemstash.gem_source"]).to eq(Gemstash::GemSource::RubygemsSource)
      expect(env["gemstash.upstream"]).to eq(upstream_url)
      expect(env["REQUEST_URI"]).to eq("/some/path?arg=abc")
      expect(env["PATH_INFO"]).to eq("/some/path")
      expect(the_log).to_not include("Rewriting ")
    end
  end

  context "ignoring an upstream defined in a header" do
    let(:env) do
      config = Gemstash::Configuration.new(config: { ignore_gemfile_source: true })
      current_env = Gemstash::Env.new(config)

      {
        "gemstash.env" => current_env,
        "REQUEST_URI" => "/some/path?arg=abc",
        "PATH_INFO" => "/some/path",
        "HTTP_X_GEMFILE_SOURCE" => upstream_url
      }
    end

    let(:upstream_url) { "https://some.gemsite.com" }
    let(:default_upstream_url) { "https://rubygems.org" }
    let(:result) { double }

    it "sets the source to RubygemsSource" do
      expect(app).to receive(:call).with(env).and_return(result)
      expect(middleware.call(env)).to eq(result)
      expect(env["gemstash.gem_source"]).to eq(Gemstash::GemSource::RubygemsSource)
      expect(env["gemstash.upstream"]).to eq(default_upstream_url)
      expect(env["REQUEST_URI"]).to eq("/some/path?arg=abc")
      expect(env["PATH_INFO"]).to eq("/some/path")
      expect(the_log).to_not include("Rewriting ")
    end
  end

  context "using the default upstream" do
    let(:env) do
      {
        "gemstash.env" => Gemstash::Env.current,
        "REQUEST_URI" => "/some/path?arg=abc",
        "PATH_INFO" => "/some/path"
      }
    end

    let(:upstream_url) { "https://rubygems.org" }
    let(:result) { double }

    it "sets the source to RubygemsSource" do
      expect(app).to receive(:call).with(env).and_return(result)
      expect(middleware.call(env)).to eq(result)
      expect(env["gemstash.gem_source"]).to eq(Gemstash::GemSource::RubygemsSource)
      expect(env["gemstash.upstream"]).to eq(upstream_url)
      expect(env["REQUEST_URI"]).to eq("/some/path?arg=abc")
      expect(env["PATH_INFO"]).to eq("/some/path")
      expect(the_log).to_not include("Rewriting ")
    end
  end
end

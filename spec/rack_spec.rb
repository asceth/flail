require 'spec_helper'

require 'ostruct'
require 'flail/rack'

describe Flail::Rack do

  subject { Flail::Rack.new lambda {|env| "val: #{env.fetch(:required_key)}" } }

  context "when an exception is raised by the app" do
    let(:env) { {} }

    it "should make an instance of Flail::Exception from the exception" do
      stub_fe = OpenStruct.new(:"handle!" => nil)
      mock(Flail::Exception).new(env, is_a(KeyError)) { stub_fe }

      # catch the re-raised KeyError so the spec isn't wrecked
      begin
        subject.call(env)
      rescue KeyError
      end
    end

    it "should handle the new Flail::Exception" do
      stub.proxy(Flail::Exception).new do |fe|
        mock(fe).handle!
      end

      begin
        subject.call(env)
      rescue KeyError
      end
    end
  end
end

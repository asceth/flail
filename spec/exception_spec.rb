# -*- coding: utf-8 -*-
require 'spec_helper'

require 'ostruct'
require 'flail/backtrace'
require 'flail/exception'

describe Flail::Exception do

  subject { Flail::Exception.new({}, Exception.new) }
  SAMPLE_BACKTRACE = [
                      "app/models/user.rb:13:in `magic'",
                      "app/controllers/users_controller.rb:8:in `index'"
                     ]

  it "should not choke on bad utf-8" do
    b1r = 0xc0..0xc2
    b2r = 0x80..0xbf
    b1r.each do |b1|
      b2r.each do |b2|
        string = [b1,b2].pack("C*")

        lambda { subject.clean_unserializable_data({:test => string}).to_json }.should_not raise_error
      end
    end
  end

  it "should be able to accept and generic error with no request attached" do
    lambda { Flail::Exception.notify(Exception.new) }.should_not raise_error
  end
end

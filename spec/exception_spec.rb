# -*- coding: utf-8 -*-
require 'spec_helper'

require 'ostruct'
require 'flail/backtrace'
require 'flail/exception'

describe Flail::Exception do
  
  #Setup flail with dummy handler as these tests aren't very complex.
  Flail.configure do
    handle do |payload|
      # Do nothing.
    end
  end

  subject { Flail::Exception.new(Exception.new, {}) }

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

  it "should be able to accept a generic exception with no request attached" do
    lambda { Flail::Exception.notify(Exception.new) }.should_not raise_error
  end
end

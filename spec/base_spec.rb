require 'spec_helper'

describe Flail do

  context "#configuration" do
    it "should return the same object for multiple calls" do
      Flail.configuration.should == Flail.configuration
    end
  end

  context "#configure" do
    it "should fail without a block" do
      lambda { Flail.configure }.should raise_error
    end

    it "should instance_eval the block onto configuration" do
      block = Proc.new { handle {|payload| } }
      mock(Flail).configuration.stub!.instance_eval(&block)
      Flail.configure(&block)
    end
  end
end


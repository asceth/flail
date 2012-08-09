require 'spec_helper'

require 'ostruct'
require 'flail/rails/rescue_action'

describe Flail::Rails::RescueAction do

  context "catching requests" do
    before do
      FlailArmory.setup
    end

    before(:each) do
      FlailArmory.raid
    end

    it "should deliver an exception raised in public requests" do
      FlailArmory.process_action_with_error
      FlailArmory.payload.should_not be_nil
    end

    it "should not deliver exceptions in local requests" do
      FlailArmory.process_action_with_error(:local => true)
      FlailArmory.payload.should be_nil
    end

    it "should not deliver exceptions when all requests are local" do
      FlailArmory.process_action_with_error(:all_local => true)
      FlailArmory.payload.should be_nil
    end

    it "should not deliver exceptions from actions that don't raise" do
      controller = FlailArmory.process_action { render :text => 'Hello' }

      FlailArmory.payload.should be_nil
      controller.response.body.should == 'Hello'
    end

    it "should send session data" do
      data = {'one' => 'two'}
      FlailArmory.process_action_with_error(:session => data)

      FlailArmory.payload['session_data'].should == data
    end

    it "should send user data" do
      user = OpenStruct.new(:attributes => {:id => 1, :login => 'jlong'})
      FlailArmory.process_action_with_error(:user => user)

      FlailArmory.payload['user'].should == {'id' => 1, 'login' => 'jlong'}
    end
  end
end

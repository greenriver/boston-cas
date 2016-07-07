require 'test_helper'

class MatchAccessContextsTest < ActiveSupport::TestCase
  
  attr_reader :subject, :controller
  
  def setup
    @subject = MatchAccessContexts
    @controller = instance_double ApplicationController
  end
  
  def test_build_when_notification_id_param_absent
    allow(controller).to receive(:params) { Hash.new }
    expect(MatchAccessContexts::AuthenticatedUser).to receive(:new).with(controller) { 'an authd user context' }
    assert_equal 'an authd user context', subject.build(controller)
  end
  
  
end
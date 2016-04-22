require "story"
require "spec_helper"

describe DelayedJobLoner do

  it "should create a job if :unique_on is not specified" do
    story = Story.create(:text => "foo")
    story.reload
    story.delay.tell.persisted?.should eql true
  end

  it "should create a job if :unique_on is specified and a similar job does not exist" do
    story = Story.create(:text => "foo")
    story2 = Story.create(:text => "foo")
    story.reload
    story2.reload

    story.delay.tell.persisted?.should eql true
    story2.delay(:unique_on => [:id]).tell.persisted?.should eql true
  end

  # This test is broken right now because of an issue with attr_accessor not being able to be set by mass assignment in my tests.
  # It works in real life...
  it "should not create a job if :loner is specified and a similar job exists" do
    story = Story.create(:text => "foo")
    story.reload

    story.whatever.persisted?.should eql true
    story.whatever.persisted?.should eql false

    story.delay(:loner => true).tell.persisted?.should eql true
    story.delay(:loner => true).tell.persisted?.should eql false
  end

  it "should not create a job if :loner is specified for class method and another call to the same method exists" do
    Story.delay(:loner => true).do_things.persisted?.should eql true
    Story.delay(:loner => true).do_things.persisted?.should eql false

    Story.delay(:loner => true).do_things_with_param(1).persisted?.should eql true
    Story.delay(:loner => true).do_things_with_param(2).persisted?.should eql false
  end

  it "should not create a job if unique_on is specified for a class method with the same method and unique value" do
    Story.delay(:unique_on => 1).do_things_with_param(1).persisted?.should eql true
    Story.delay(:unique_on => 2).do_things_with_param(1).persisted?.should eql true
    Story.delay(:unique_on => 1).do_things_with_param(1).persisted?.should eql false
    Story.delay(:unique_on => 2).do_things_with_param(1).persisted?.should eql false
  end

  it "should return a unique md5 hash" do
    story = Story.create(:text => "foo")
    story2 = Story.create(:text => "foo")
    story.reload
    story2.reload

    dj_object = story.whatever
    dj_object2 = story2.whatever

    dj_object.generate_loner_hash.should_not eql dj_object2.generate_loner_hash
    dj_object.loner_hash.should eql dj_object.generate_loner_hash
  end

end

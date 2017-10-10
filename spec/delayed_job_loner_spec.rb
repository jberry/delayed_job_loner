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

  it "should not create a job if :loner is specified and a similar job exists" do
    story = Story.create(:text => "foo")
    story.reload

    story.whatever.persisted?.should eql true
    story.whatever.persisted?.should eql false

    story.delay(:loner => true).tell.persisted?.should eql true
    story.delay(:loner => true).tell.persisted?.should eql false
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

  it "works with Job.enqueue options" do
    story = Story.create(:text => "foo")
    job   = Delayed::Job.enqueue(PerformStoryJob.new(story), unique_on: [:story_id])
    job2  = Delayed::Job.enqueue(PerformStoryJob.new(story), unique_on: [:story_id])

    expect(job).to be_persisted
    expect(job2).to_not be_persisted
  end

  it "allows unique_on to be a single symbol" do
    story = Story.create(:text => "foo")
    job   = Delayed::Job.enqueue(PerformStoryJob.new(story), unique_on: :story_id)
    expect(job).to be_persisted
  end
end

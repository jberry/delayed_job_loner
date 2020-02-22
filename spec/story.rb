require 'rails'
require 'delayed_job'
require 'delayed_job_active_record'
require 'delayed_job_loner'
require 'sqlite3_ar_regexp'

ActiveRecord::Base.logger = Logger.new('/tmp/dj.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/tmp/jobs.sqlite')
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.default_timezone = :utc if Time.zone.nil?

ActiveRecord::Schema.define do

  create_table :delayed_jobs, force: true do |table|
    table.integer :priority, default: 0, null: false # Allows some jobs to jump to the front of the queue
    table.integer :attempts, default: 0, null: false # Provides for retries, but still fail eventually.
    table.text :handler,                 null: false # YAML-encoded string of the object that will do work
    table.text :last_error                           # reason for last failure (See Note below)
    table.datetime :run_at                           # When to run. Could be Time.zone.now for immediately, or sometime in the future.
    table.datetime :locked_at                        # Set when a client is working on this object
    table.datetime :failed_at                        # Set when all retries have failed (actually, by default, the record is deleted instead)
    table.string :locked_by                          # Who is working on this object (if locked)
    table.string :queue                              # The name of the queue this job is in
    table.timestamps null: true
    table.string   :loner_hash
    table.string   :loner_conflict
  end

  add_index :delayed_jobs, [:priority, :run_at], name: "delayed_jobs_priority"

  create_table :stories, force: true do |table|
    table.string :text
  end

end

# Purely useful for test cases...
class Story < ActiveRecord::Base
  attr_accessor :id

  def tell
    text
  end

  def whatever
    tell
  end
  handle_asynchronously :whatever, :loner => true, :priority => 10

end

class PerformStoryJob
  attr_reader :story_id

  def initialize(story)
    @story_id = story.id
  end

  def perform
    story.tell
  end

  def story
    Story.find(@story_id)
  end
end

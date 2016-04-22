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

  create_table :delayed_jobs, :force => true do |table|
    table.integer  :priority, :default => 0
    table.integer  :attempts, :default => 0
    table.text     :handler
    table.string   :last_error
    table.datetime :run_at
    table.datetime :locked_at
    table.string   :locked_by
    table.datetime :failed_at
    table.string   :queue
    table.string   :loner_hash
    table.timestamps

  end

  create_table :stories, :force => true do |table|
    table.string :text
  end

end

# Purely useful for test cases...
class Story < ActiveRecord::Base
  def tell
    text
  end

  def whatever
    tell
  end
  handle_asynchronously :whatever, :loner => true, :priority => 10

end

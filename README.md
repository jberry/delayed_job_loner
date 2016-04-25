# DelayedJobLoner

Adds an option on handle_asynchronously or delay that specifies which attributes to check for uniqueness on. A new job will not be created if one already exists for that method and object.

## Installation

Add this line to your application's Gemfile:

    gem 'delayed_job_loner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install delayed_job_loner

### Migration

The jobs table requires a migration to add the loner_hash string field.

<pre>
$ script/rails generate delayed_job_loner
$ rake db:migrate
</pre>

## Usage

Pass the option `:loner` or `:unique_on` to any method that you would provide `:priority` or `:run_at`. `:unique_on` should be an array of attributes that you want to check the uniqueness of the job against.

* `:loner` just specifies that the job should be unique and will only check against the method name and object id
* `:unique_on` allows you to specify the fields that it will check uniqueness against

Here is an example:
```ruby
class Foo < ActiveRecord::Base
  def do_all_the_things
    # All the things!
  end
  handle_asynchronously :do_all_the_things, :unique_on => [:name, :other]

  def do_some_of_the_things
    # Some of the things!
  end
end
```

This allows you to do things like this:
```ruby
foo = Foo.first
foo.do_all_the_things
  # Creates a new job
foo.do_all_the_things
  # Doesn't create a new job because we already created one

foo.delay(:priority => 10).do_some_of_the_things
  # Creates a new job
foo.delay(:priority => 10, :loner => true).do_some_of_the_things
  # Doesn't create a new job
foo.delay(:priority => 10).do_some_of_the_things
  # Creates a new job because we didn't specify :unique_on
```

You can use loner to prevent duplicate Class level methods too
```ruby
Foo.delay.do_some_things()
  # Creates a new job
Foo.delay(loner: true).do_some_things()
  # Doesn't create a new job
```

Or use unique_on to specific a unique value for Class level methods
```ruby
Foo.delay.do_some_things(1235)
  # Creates a new job
Foo.delay(unique_on: 1235).do_some_things(1235)
  # Doesn't create a new job
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

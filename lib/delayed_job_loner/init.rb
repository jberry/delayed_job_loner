require 'digest/md5'

module Delayed
  module Backend
    module ActiveRecord
      class Job < ::ActiveRecord::Base
        attr_accessor :loner
        attr_accessor :unique_on

        validate :check_uniqueness

        def check_uniqueness
          if loner || unique_on
            self.loner_hash = generate_loner_hash
            self.errors.add(:base, "Job already exists") unless self.class.where(loner_hash: self.loner_hash, locked_by: nil).first.nil?
          else
            true
          end
        end

        def generate_loner_hash
          job_name = payload_object.kind_of?(PerformableMethod) ? payload_object.method_name : payload_object.class.name
          if unique_on
            hashable_string = "#{job_name}"
            unique_on.each do |attribute_name|
              hashable_string += "::#{attribute_name}:#{payload_object.send(attribute_name)}"
            end
          else
            hashable_string = "#{job_name}::id:#{payload_object.id}"
          end
          Digest::MD5.base64digest(hashable_string)
        end
      end
    end
  end
end

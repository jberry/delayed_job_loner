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
          if unique_on
            hashable_string = "#{payload_object.method_name}"
            if payload_object.object.is_a?(Class)
              Array(unique_on).each do |value|
                hashable_string += "::#{value}"
              end
            else
              unique_on.each do |attribute_name|
                hashable_string += "::#{attribute_name}:#{payload_object.send(attribute_name)}"
              end
            end
          else
            hashable_string = "#{payload_object.method_name}"
            hashable_string += "::id:#{payload_object.id}" unless payload_object.object.is_a?(Class)

          end
          Digest::MD5.base64digest(hashable_string)
        end

      end
    end
  end
end

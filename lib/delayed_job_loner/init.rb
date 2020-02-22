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
          attrs    = Array(unique_on || :id)
          hashval  = "#{name}::" + attrs.map {|attr| "#{attr}:#{payload_object.send(attr)}"}.join('::')
          Digest::MD5.base64digest(hashval)
        end
      end
    end
  end
end

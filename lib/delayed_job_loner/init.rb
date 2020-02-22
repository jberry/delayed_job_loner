require 'digest/md5'

module Delayed
  module Backend
    module ActiveRecord
      class Job < ::ActiveRecord::Base
        attr_accessor :loner
        attr_accessor :unique_on
        attr_accessor :store_conflict_id_from

        validate :check_uniqueness

        def check_uniqueness
          if loner || unique_on
            self.loner_hash = generate_loner_hash
            conflict = self.class.where(loner_hash: self.loner_hash).first
            unless conflict.nil?
              self.errors.add(:base, "Job already exists")
              if store_conflict_id_from
                self.loner_conflict = conflict.payload_object.send(store_conflict_id_from)
              end
            end
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

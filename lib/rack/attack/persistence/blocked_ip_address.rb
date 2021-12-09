require "resolv"

module Rack
  class Attack
    module Persistence

      class BlockedIpAddress < ActiveRecord::Base

        after_create :create_in_cache

        after_destroy :remove_from_cache

        validates :ip_address, format: {
          with: Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex)
        }

        def self.blocked?(ip_address)
          Rails.cache.read(blocked_cache_key(ip_address)) ? true : false
        end

        def self.block(ip_address)
          create ip_address: ip_address
        end

        def self.unblock(ip_address)
          blocked_ip_address = find_by(ip_address: ip_address)
          blocked_ip_address.unblock
        end

        def unblock
          destroy
        end

        private

        def create_in_cache
          Rails.cache.write(blocked_cache_key(ip_address), true)
        end

        def remove_from_cache
          Rails.cache.delete(blocked_cache_key(ip_address))
        end

        def self.blocked_cache_key(ip_address)
          "block_ip #{ip_address}"
        end

        def blocked_cache_key(ip_address)
          "block_ip #{ip_address}"
        end
      end
    end
  end
end

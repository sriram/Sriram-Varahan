#--
# Copyright (c) 2009-2010, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'rufus/tokyo/hmethods'
require 'rufus/tokyo/transactions'
require 'rufus/tokyo/openable'


module Rufus::Edo

  #
  # The base cabinet methods are gathered here. They focus on wrapping
  # Hirabayashi-san's methods.
  #
  # This module is included by Edo::Cabinet and Edo::NTyrant. Placing the
  # methods in this module avoids having to load 'TokyoCabinet' when using
  # only rufus/edo/ntyrant.
  #
  module CabinetCore

    include Rufus::Tokyo::HashMethods
    include Rufus::Tokyo::Transactions

    # Add the open() method to all Cabinet type classes.
    def self.included(target)
      target.extend(Rufus::Tokyo::Openable)
    end

    # Returns the path to this database.
    #
    def path

      @path
    end

    # No comment
    #
    def []= (k, v)

      k = k.to_s; v = v.to_s

      @db.put(k, v) || raise_error
    end

    # Like #put but doesn't overwrite the value if already set. Returns true
    # only if there no previous entry for k.
    #
    def putkeep (k, v)

      k = k.to_s; v = v.to_s

      @db.putkeep(k, v)
    end

    # Appends the given string at the end of the current string value for key k.
    # If there is no record for key k, a new record will be created.
    #
    # Returns true if successful.
    #
    def putcat (k, v)

      k = k.to_s; v = v.to_s

      @db.putcat(k, v)
    end

    # (The actual #[] method is provided by HashMethods)
    #
    def get (k)

      @db.get(k.to_s)
    end
    protected :get

    # Removes a record from the cabinet, returns the value if successful
    # else nil.
    #
    def delete (k)

      k = k.to_s
      v = self[k]

      @db.out(k) ? v : nil
    end

    # Returns the number of records in the 'cabinet'
    #
    def size

      @db.rnum
    end

    # Removes all the records in the cabinet (use with care)
    #
    # Returns self (like Ruby's Hash does).
    #
    def clear

      @db.vanish || raise_error

      self
    end

    # Returns the 'weight' of the db (in bytes)
    #
    def weight

      @db.fsiz
    end

    # Closes the cabinet (and frees the datastructure allocated for it),
    # returns true in case of success.
    #
    def close

      @db.close || raise_error
    end

    # Copies the current cabinet to a new file.
    #
    # Returns true if it was successful.
    #
    def copy (target_path)

      @db.copy(target_path)
    end

    # Copies the current cabinet to a new file.
    #
    # Does it by copying each entry afresh to the target file. Spares some
    # space, hence the 'compact' label...
    #
    def compact_copy (target_path)

      @other_db = self.class.new(target_path)
      self.each { |k, v| @other_db[k] = v }
      @other_db.close
    end

    # "synchronize updated contents of an abstract database object with
    # the file and the device"
    #
    def sync

      @db.sync || raise_error
    end

    # Returns an array of all the primary keys in the db.
    #
    # With no options given, this method will return all the keys (strings)
    # in a Ruby array.
    #
    #   :prefix --> returns only the keys who match a given string prefix
    #
    #   :limit --> returns a limited number of keys
    #
    def keys (options={})

      if @db.respond_to? :fwmkeys
        pref = options.fetch(:prefix, "")

        @db.fwmkeys(pref, options[:limit] || -1)
      elsif @db.respond_to? :range
        @db.range("[min,max]", nil)
      else
        raise NotImplementedError, "Database does not support keys()"
      end
    end

    # Deletes all the entries whose keys begin with the given prefix
    #
    def delete_keys_with_prefix (prefix)

      # only ADB has the #misc method...

      if @db.respond_to?(:misc)
        @db.misc('outlist', @db.fwmkeys(prefix, -1))
      else
        @db.fwmkeys(prefix, -1).each { |k| self.delete(k) }
      end

      nil
    end

    # Given a list of keys, returns a Hash { key => value } of the
    # matching entries (in one sweep).
    #
    # Warning : this is a naive (slow) implementation.
    #
    def lget (*keys)

      keys = keys.flatten.collect { |k| k.to_s }

      # only ADB has the #misc method...

      if @db.respond_to?(:misc)
        Hash[*@db.misc('getlist', keys)]
      else
        keys.inject({}) { |h, k| v = self[k]; h[k] = v if v; h }
      end
    end

    alias :mget :lget

    # Default impl provided by HashMethods
    #
    def merge! (hash)

      # only ADB has the #misc method...

      if @db.respond_to?(:misc)
        @db.misc('putlist', hash.to_a.flatten)
      else
        super(hash)
      end
      self
    end
    alias :lput :merge!

    # Given a list of keys, deletes all the matching entries (in one sweep).
    #
    # Warning : this is a naive (slow) implementation.
    #
    def ldelete (*keys)

      keys = keys.flatten.collect { |k| k.to_s }

      # only ADB has the #misc method...

      if @db.respond_to?(:misc)
        @db.misc('outlist', keys)
      else
        keys.each { |k| self.delete(k) }
      end

      nil
    end

    # Increments the value stored under the given key with the given increment
    # (defaults to 1 (integer)).
    #
    # Warning : Tokyo Cabinet/Tyrant doesn't store counter values as regular
    # strings (db['key'] won't yield something that replies properly to #to_i)
    #
    # Use #counter_value(k) to get the current value set for the counter.
    #
    def incr (key, val=1)

      key = key.to_s

      v = val.is_a?(Fixnum) ? @db.addint(key, val) : @db.adddouble(key, val)

      raise(EdoError.new(
        "incr failed, there is probably already a string value set " +
        "for the key '#{key}'. Make sure there is no value before incrementing"
      )) unless v

      v
    end
    alias :adddouble :incr
    alias :addint :incr
    alias :add_double :incr
    alias :add_int :incr

    # Returns the current value for a counter (a float or an int).
    #
    # See #incr
    #
    def counter_value (key)

      incr(key, 0.0) rescue incr(key, 0)
    end

    # Triggers a defrag (TC >= 1.4.21 only)
    #
    def defrag

      #raise(NotImplementedError.new(
      #  "defrag (misc) only available when opening db with :type => :abstract"
      #)) unless @db.respond_to?(:misc)

      @db.misc('defrag', [])
    end

    # Returns the underlying 'native' Ruby object (of the class devised by
    # Hirabayashi-san)
    #
    def original

      @db
    end

    # This is rather low-level, you'd better use #transaction like in
    #
    #   db.transaction do
    #     db['a'] = 'alpha'
    #     db['b'] = 'bravo'
    #     db.abort if something_went_wrong?
    #   end
    #
    # Note that fixed-length dbs do not support transactions. It will result
    # in a NoMethodError.
    #
    def tranbegin
      @db.tranbegin
    end

    # This is rather low-level use #transaction and a block for a higher-level
    # technique.
    #
    # Note that fixed-length dbs do not support transactions. It will result
    # in a NoMethodError.
    #
    def trancommit
      @db.trancommit
    end

    # This is rather low-level use #transaction and a block for a higher-level
    # technique.
    #
    # Note that fixed-length dbs do not support transactions. It will result
    # in a NoMethodError.
    #
    def tranabort
      @db.tranabort
    end

    protected

    def raise_error
      code = @db.ecode
      message = @db.errmsg(code)
      raise EdoError.new("(err #{code}) #{message}")
    end
  end
end


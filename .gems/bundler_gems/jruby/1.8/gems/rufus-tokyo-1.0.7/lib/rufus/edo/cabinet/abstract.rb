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


require 'tokyocabinet' # gem install careo-tokyocabinet

require 'rufus/edo/cabcore'
require 'rufus/tokyo/config'


module Rufus::Edo

  #
  # A cabinet wired 'natively' to the libtokyocabinet.dynlib (approximatevely
  # 2 times faster than the wiring over FFI).
  #
  # This class has the exact same methods as Rufus::Tokyo::Cabinet. It's faster
  # though. The advantage of Rufus::Tokyo::Cabinet lies in that in runs on
  # Ruby 1.8, 1.9 and JRuby.
  #
  # You need to have Hirabayashi-san's binding installed to use this
  # Rufus::Edo::Cabinet :
  #
  #   http://github.com/jmettraux/rufus-tokyo/tree/master/lib/rufus/edo
  #
  # You can then write code like :
  #
  #   require 'rubygems'
  #   require 'rufus/edo' # sudo gem install rufus-tokyo
  #
  #   db = Rufus::Edo::Cabinet.new('data.tch')
  #
  #   db['hello'] = 'world'
  #
  #   puts db['hello']
  #     # -> 'world'
  #
  #   db.close
  #
  # This cabinet wraps hashes, b+ trees and fixed length databases. For tables,
  # see Rufus::Edo::Table
  #
  class Cabinet

    include Rufus::Edo::CabinetCore
    include Rufus::Tokyo::CabinetConfig

    # Initializes and open a cabinet (hash, b+ tree or fixed-size)
    #
    # db = Rufus::Edo::Cabinet.new('data.tch')
    #   # or
    # db = Rufus::Edo::Cabinet.new('data', :type => :hash)
    #
    # 3 types are recognized :hash (.tch), :btree (.tcb) and :fixed (.tcf). For
    # tables, see Rufus::Edo::Table
    #
    # == parameters
    #
    # There are two ways to pass parameters at the opening of a db :
    #
    #   db = Rufus::Edo::Cabinet.new('data.tch#opts=ld#mode=w') # or
    #   db = Rufus::Edo::Cabinet.new('data.tch', :opts => 'ld', :mode => 'w')
    #
    # most verbose :
    #
    #   db = Rufus::Edo::Cabinet.new(
    #     'data', :type => :hash, :opts => 'ld', :mode => 'w')
    #
    # === :mode
    #
    #   * :mode    a set of chars ('r'ead, 'w'rite, 'c'reate, 't'runcate,
    #              'e' non locking, 'f' non blocking lock), default is 'wc'
    #
    # === :default and :default_proc
    #
    # Much like a Ruby Hash, a Cabinet accepts a default value or a default_proc
    #
    #   db = Rufus::Edo::Cabinet.new('data.tch', :default => 'xxx')
    #   db['fred'] = 'Astaire'
    #   p db['fred'] # => 'Astaire'
    #   p db['ginger'] # => 'xxx'
    #
    #   db = Rufus::Edo::Cabinet.new(
    #     'data.tch',
    #     :default_proc => lambda { |cab, key| "not found : '#{k}'" }
    #   p db['ginger'] # => "not found : 'ginger'"
    #
    # The first arg passed to the default_proc is the cabinet itself, so this
    # opens up interesting possibilities.
    #
    #
    # === other parameters
    #
    # 'On-memory hash database supports "bnum", "capnum", and "capsiz".
    #  On-memory tree database supports "capnum" and "capsiz".
    #  Hash database supports "mode", "bnum", "apow", "fpow", "opts",
    #  "rcnum", and "xmsiz".
    #  B+ tree database supports "mode", "lmemb", "nmemb", "bnum", "apow",
    #  "fpow", "opts", "lcnum", "ncnum", "xmsiz", and "cmpfunc".
    #  Fixed-length database supports "mode", "width", and "limsiz"'
    #
    #   * :opts    a set of chars ('l'arge, 'd'eflate, 'b'zip2, 't'cbs)
    #              (usually empty or something like 'ld' or 'lb')
    #
    #   * :bnum    number of elements of the bucket array
    #   * :apow    size of record alignment by power of 2 (defaults to 4)
    #   * :fpow    maximum number of elements of the free block pool by
    #              power of 2 (defaults to 10)
    #
    #   * :rcnum   specifies the maximum number of records to be cached.
    #              If it is not more than 0, the record cache is disabled.
    #              It is disabled by default.
    #   * :lcnum   specifies the maximum number of leaf nodes to be cached.
    #              If it is not more than 0, the default value is specified.
    #              The default value is 2048.
    #   * :ncnum   specifies the maximum number of non-leaf nodes to be
    #              cached. If it is not more than 0, the default value is
    #              specified. The default value is 512.
    #
    #   * :lmemb   number of members in each leaf page (defaults to 128) (btree)
    #   * :nmemb   number of members in each non-leaf page (default 256) (btree)
    #
    #   * :width   width of the value of each record (default 255) (fixed)
    #   * :limsiz  limit size of the database file (default 268_435_456) (fixed)
    #
    #   * :xmsiz   specifies the size of the extra mapped memory. If it is
    #              not more than 0, the extra mapped memory is disabled.
    #              The default size is 67108864.
    #
    #   * :capnum  specifies the capacity number of records.
    #   * :capsiz  specifies the capacity size of using memory.
    #
    #   * :dfunit  unit step number. If it is not more than 0,
    #              the auto defragmentation is disabled. (Since TC 1.4.21)
    #
    #   * :cmpfunc the comparison function used to order a b-tree database.  Can
    #              be set to :lexical (default), :decimal, or a Proc object that
    #              implements a <=>-like comparison function for the two keys it
    #              will be passed.  Custom comparisons must be set each time the
    #              database is opened.
    #
    #
    # = NOTE :
    #
    # On reopening a file, Cabinet will tend to stick to the parameters as
    # set when the file was opened. To change that, have a look at the
    # man pages of the various command line tools coming with Tokyo Cabinet.
    #
    def initialize (path, params={})

      conf = determine_conf(path, params)

      klass = {
        :abstract => defined?(TokyoCabinet::ADB) ?
          TokyoCabinet::ADB : TokyoCabinet::HDB,
        :hash => TokyoCabinet::HDB,
        :btree => TokyoCabinet::BDB,
        :fixed => TokyoCabinet::FDB
      }[conf[:type]]

      @db = klass.new

      #
      # tune

      tuning_parameters = case conf[:type]
        when :abstract then nil
        when :hash then [ :bnum, :apow, :fpow, :opts ]
        when :btree then [ :lmemb, :nmemb, :bnum, :apow, :fpow, :opts ]
        when :fixed then [ :width, :limsiz ]
      end

      @db.tune(*tuning_parameters.collect { |o| conf[o] }) \
        if tuning_parameters

      #
      # set cache

      cache_values = case conf[:type]
        when :abstract then nil
        when :hash then [ :rcnum ]
        when :btree then [ :lcnum, :ncnum ]
        when :fixed then nil
      end

      @db.setcache(*cache_values.collect { |o| conf[o] }) \
        if cache_values

      #
      # set xmsiz

      @db.setxmsiz(conf[:xmsiz]) \
        unless [ :abstract, :fixed ].include?(conf[:type])

      #
      # set dfunit (TC > 1.4.21)

      @db.setdfunit(conf[:dfunit]) \
        if @db.respond_to?(:setdfunit)

      #
      # set cmp_func

      if @db.respond_to? :setcmpfunc
        case conf[:cmpfunc]
        when :lexical
          @db.setcmpfunc(TokyoCabinet::BDB::CMPLEXICAL)
        when :decimal
          @db.setcmpfunc(TokyoCabinet::BDB::CMPDECIMAL)
        when Proc
          @db.setcmpfunc(conf[:cmpfunc])
        end
      end

      #
      # open

      @path = conf[:path]

      if @db.class.name == 'TokyoCabinet::ADB'
        @db.open(@path) || raise_error
      else
        @db.open(@path, conf[:mode]) || raise_error
      end

      #
      # default

      self.default = params[:default]
      @default_proc ||= params[:default_proc]
    end

    # This is a B+ Tree method only, puts a value for a key who has
    # [potentially] multiple values.
    #
    def putdup (k, v)

      @db.putdup(k, v)
    end

    # This is a B+ Tree method only, returns all the values for a given
    # key.
    #
    def get4 (k)

      @db.getlist(k)
    end
    alias :getdup :get4
  end
end


#--
# Copyright (c) 2009-2010, Jeremy Hinegardner, John Mettraux
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


module Rufus::Tokyo

  #
  # The libtokyodystopia.so methods get bound to this module
  #
  module DystopiaLib #:nodoc#

    extend FFI::Library

    #
    # find Tokyo Dystopia lib

    paths = Array(ENV['TOKYO_DYSTOPIA_LIB'] || Dir['/{opt,usr}/{,local/}lib{,64}/libtokyodystopia.{dylib,so*}'])

    begin
      ffi_lib(*paths)
    rescue LoadError => le
      raise "did not find Tokyo Dystopia libs on your system"
    end

    #
    # tcidb functions - The Core API
    #
    # http://1978th.net/tokyodystopia/spex.html#dystopiaapi

    # tuning options <dystopia.h>
    LARGE   = 1 << 0
    DEFLATE = 1 << 1
    BZIP    = 1 << 2
    TCBS    = 1 << 3

    # open modes <dystopia.h>
    READER  = 1 << 0
    WRITER  = 1 << 1
    CREAT   = 1 << 2
    TRUNC   = 1 << 3
    NOLCK   = 1 << 4
    LCKNB   = 1 << 5

    # for get modes
    SUBSTR = 0
    PREFIX = 1
    SUFFIX = 2
    FULL   = 3
    TOKEN  = 4
    TOKPRE = 5
    TOKSUF = 6


    attach_function :tcidberrmsg,    [ :int ], :string
    attach_function :tcidbecode,     [ :pointer ], :int

    attach_function :tcidbnew,       [], :pointer
    attach_function :tcidbopen,      [ :pointer, :pointer, :int ], :bool
    attach_function :tcidbclose,     [ :pointer ], :bool
    attach_function :tcidbdel,       [ :pointer ], :void
    attach_function :tcidbvanish,    [ :pointer ], :bool

    # TODO
    #attach_function :tcidbtune,      [ :pointer, :int64, :int64, :int64, :int8 ], :bool
    #attach_function :tcidbsetcache,  [ :pointer, :int64, :int32 ], :bool
    #attach_function :tcidbsetfwmmax, [ :pointer, :uint32 ], :bool
    #attach_function :tcidbsync,      [ :pointer ], :bool
    #attach_function :tcidboptimize,  [ :pointer ], :bool
    #attach_function :tcidbcopy,      [ :pointer, :pointer ], :bool

    attach_function :tcidbpath,      [ :pointer ], :string
    attach_function :tcidbrnum,      [ :pointer ], :uint64
    attach_function :tcidbfsiz,      [ :pointer ], :uint64

    attach_function :tcidbput,       [ :pointer, :int64, :string ], :bool
    attach_function :tcidbout,       [ :pointer, :int64 ], :bool
    attach_function :tcidbget,       [ :pointer, :int64 ], :string
    #attach_function :tcidbsearch,    [ :pointer, :pointer, :int, :pointer ], :pointer
    attach_function :tcidbsearch2,   [ :pointer, :string, :pointer], :pointer
    #attach_function :tcidbiterinit,  [ :pointer ], :bool
    #attach_function :tcidbiternext,  [ :pointer ], :uint64


    #
    # tcwdb functions - The Word Database API
    #
    # http://1978th.net/tokyodystopia/spex.html#tcwdbapi

    attach_function :tcwdbnew, [], :pointer

    attach_function :tcwdbopen, [ :pointer, :string, :int ], :bool
    attach_function :tcwdbclose, [ :pointer ], :bool

    attach_function :tcwdbecode, [ :pointer ], :int

    attach_function :tcwdbput2, [ :pointer, :int64, :string, :string ], :pointer
  end
end


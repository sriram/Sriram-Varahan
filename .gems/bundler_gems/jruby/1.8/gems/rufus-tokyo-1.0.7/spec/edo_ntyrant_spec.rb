
#
# Specifying rufus-tokyo
#
# Mon Feb 23 23:24:45 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'
require File.dirname(__FILE__) + '/shared_abstract_spec'
require File.dirname(__FILE__) + '/shared_tyrant_spec'

begin
  require 'rufus/edo/ntyrant'
rescue LoadError
  puts "'TokyoTyrant' ruby lib not available on this ruby platform"
end

if defined?(Rufus::Edo)

  describe 'a missing Rufus::Edo::NetTyrant' do

    it 'should raise an error' do

      lambda {
        Rufus::Edo::NetTyrant.new('tyrant.example.com', 45000)
      }.should.raise(Rufus::Edo::EdoError).message.should.equal(
        '(err 2) host not found')
    end
  end
  
  describe Rufus::Edo::NetTyrant do

    it 'should use open with a block will auto close the db correctly' do

      res = Rufus::Edo::NetTyrant.open('127.0.0.1', 45000) do |cab|
        cab.clear
        10.times { |i| cab["key #{i}"] = "val #{i}" }
        cab.size.should.equal(10)
        :result
      end

      res.should.equal(:result)

      cab = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      10.times do |i|
        cab["key #{i}"].should.equal("val #{i}")
      end
      cab.close
    end


    it 'should use open without a block just like calling new correctly' do

      cab = Rufus::Edo::NetTyrant.open('127.0.0.1', 45000)
      cab.clear
      10.times { |i| cab["key #{i}"] = "val #{i}" }
      cab.size.should.equal(10)
      cab.close

      cab = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      10.times do |i|
        cab["key #{i}"].should.equal("val #{i}")
      end
      cab.close
    end
  end

  describe Rufus::Edo::NetTyrant do

    it 'should open and close' do

      should.not.raise {
        t = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
        t.close
      }
    end

    it 'should refuse to connect to a TyrantTable' do

      lambda {
        t = Rufus::Edo::NetTyrant.new('127.0.0.1', 45001)
      }.should.raise(ArgumentError)
    end
  end

  describe Rufus::Edo::NetTyrant do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      #puts @t.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like "an abstract structure"

    it 'should respond to stat' do

      stat = @db.stat
      stat['type'].should.equal('hash')
    end

    behaves_like 'a Tyrant structure (no transactions)'
    behaves_like 'a Tyrant structure (copy method)'
  end

  describe Rufus::Edo::NetTyrant do

    before do
      @n = 50
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
      @n.times { |i| @db["person#{i}"] = 'whoever' }
      @n.times { |i| @db["animal#{i}"] = 'whichever' }
      @db["toto#{0.chr}5"] = 'toto'
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #keys'
  end

  describe 'Rufus::Edo::NetTyrant lget/lput/ldelete' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
      3.times { |i| @db[i.to_s] = "val#{i}" }
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #lget/lput/ldelete'
  end

  describe 'Rufus::Edo::NetTyrant#add{int|double}' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #add{int|double}'
  end

  describe Rufus::Edo::NetTyrant do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #putkeep'
    behaves_like 'abstract structure #putcat'
  end

  describe 'Rufus::Edo::NetTyrant (lua extensions)' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'tyrant with embedded lua'
  end

  describe Rufus::Edo::NetTyrant do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'an abstract structure flattening keys and values'
  end

  describe 'Rufus::Edo::NetTyrant with a default value' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000, :default => 'Nemo')
      @db.clear
      @db['known'] = 'Ulysse'
    end
    after do
      @db.close
    end

    behaves_like 'an abstract structure with a default value'
  end

  describe 'Rufus::Edo::Tyrant with a default_proc' do

    before do
      @db = Rufus::Edo::NetTyrant.new(
        '127.0.0.1',
        45000,
        :default_proc => lambda { |db, k| "default:#{k}" })
      @db.clear
      @db['known'] = 'Ulysse'
    end
    after do
      @db.close
    end

    behaves_like 'an abstract structure with a default_proc'
  end
end


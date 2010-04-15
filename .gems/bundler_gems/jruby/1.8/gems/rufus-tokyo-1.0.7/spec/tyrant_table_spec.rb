
#
# Specifying rufus-tokyo
#
# Sun Feb  8 22:55:11 JST 2009
#

require File.join(File.dirname(__FILE__), 'spec_base')
require File.join(File.dirname(__FILE__), 'shared_table_spec')
require File.dirname(__FILE__) + '/shared_tyrant_spec'

require 'rufus/tokyo/tyrant'


describe 'a missing Rufus::Tokyo::TyrantTable' do

  it 'should raise an error' do

    lambda {
      Rufus::Tokyo::TyrantTable.new('127.0.0.1', 1)
    }.should.raise(Rufus::Tokyo::TokyoError).message.should.equal(
      "couldn't connect to tyrant at 127.0.0.1:1")
  end
end

describe 'Rufus::Tokyo::TyrantTable' do

  it 'should refuse to connect to a plain Tyrant' do

    lambda {
      t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45000)
    }.should.raise(ArgumentError)
  end
end

describe Rufus::Tokyo::TyrantTable do

  it 'should use open with a block will auto close the db correctly' do

    res = Rufus::Tokyo::TyrantTable.open('127.0.0.1', 45001) do |table|
      table.clear
      10.times { |i| table["key #{i}"] = {:val => i} }
      table.size.should.equal(10)
      :result
    end

    res.should.equal(:result)

    table = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    10.times do |i|
      table["key #{i}"].should.equal({"val" => i.to_s})
    end
    table.close
  end


  it 'should use open without a block just like calling new correctly' do

    table = Rufus::Tokyo::TyrantTable.open('127.0.0.1', 45001)
    table.clear
    10.times { |i| table["key #{i}"] = {:val => i} }
    table.size.should.equal(10)
    table.close

    table = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    10.times do |i|
      table["key #{i}"].should.equal({"val" => i.to_s})
    end
    table.close
  end
end

describe Rufus::Tokyo::TyrantTable do

  before do
    @t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    #puts @t.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
    @t.clear
  end
  after do
    @t.close
  end

  it 'should respond to stat' do

    @t.stat['type'].should.equal('table')
  end

  behaves_like 'table'
  behaves_like 'a Tyrant structure (no transactions)'
end

describe Rufus::Tokyo::TyrantTable do

  before do
    @t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    @t.clear
  end
  after do
    @t.close
  end

  it 'should not support transactions' do
    lambda {
      @t.transaction {}
    }.should.raise(NoMethodError)
    lambda {
      @t.abort
    }.should.raise(NoMethodError)
  end
end

describe 'Rufus::Tokyo::Table #keys' do

  before do
    @n = 50
    @t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    @t.clear
    @n.times { |i| @t["person#{i}"] = { 'name' => 'whoever' } }
    @n.times { |i| @t["animal#{i}"] = { 'name' => 'whichever' } }
    @t["toto#{0.chr}5"] = { 'name' => 'toto' }
  end
  after do
    @t.close
  end

  behaves_like 'table #keys'
end

def prepare_table_with_data (port)
  t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', port)
  t.clear
  t['pk0'] = { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' }
  t['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
  t['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
  t['pk3'] = { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
  t
end

describe Rufus::Tokyo::TyrantTable do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
    # TODO : well there are trailing indexes now... :(
  end

  behaves_like 'table indexes'
end

describe 'Rufus::Tokyo::TyrantTable#lget' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table lget'
end

describe 'a Tokyo Tyrant table, like a Ruby Hash,' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table like a hash'
end

describe 'queries on Tokyo Tyrant tables' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table query'
end

describe 'Queries on Tokyo Tyrant tables' do

  before do
    @t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    @t.clear
    [
      "consul readableness choleric hopperdozer juckies",
      "fume overharshness besprinkler whirling erythrene",
      "trumper defiable detractively cattiness superioress",
      "vivificative consul agglomerated Peterloo way",
      "unkilned bituminate antimatrimonial uran polyphony",
      "kurumaya unannexed renownedly apetaloid consul",
      "overdare nescience seronegative nagster overfatten",
    ].each_with_index { |w, i|
      @t["pk#{i}"] = { 'name' => "lambda#{i}", 'words' => w }
    }
  end
  after do
    @t.close
  end

  behaves_like 'table query (fts)'
end

describe 'Tokyo Tyrant and TableQuery#process' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  # TODO : orly ?

  #behaves_like 'table query #process'

  it 'should not work' do

    lambda {
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.process { |k, v|
      }.free
    }.should.raise(NoMethodError)
  end
end

describe 'results from Tokyo Tyrant table queries' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table query results'
end

describe 'Rufus::Tokyo::TyrantTable (lua extensions)' do

  before do
    @t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    @t.clear
  end
  after do
    @t.close
  end

  behaves_like 'tyrant table with embedded lua'
end

describe Rufus::Tokyo::TyrantTable do

  before do
    @t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
    @t.clear
  end
  after do
    @t.close
  end

  behaves_like 'a table structure flattening keys and values'
end

describe 'Rufus::Tokyo::TyrantTable\'s queries' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'a table structure to_s-ing query stuff'
end

describe 'Rufus::Tokyo::Table and metasearch' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table query metasearch'
end


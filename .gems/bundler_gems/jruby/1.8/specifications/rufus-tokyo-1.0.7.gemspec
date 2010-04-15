# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rufus-tokyo}
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mettraux", "Zev Blut", "Jeremy Hinegardner", "James Edward Gray II"]
  s.date = %q{2010-02-10}
  s.description = %q{
Ruby-ffi based lib to access Tokyo Cabinet and Tyrant.

The ffi-based structures are available via the Rufus::Tokyo namespace.
There is a Rufus::Edo namespace that interfaces with Hirabayashi-san's native Ruby interface, and whose API is equal to the Rufus::Tokyo one.

Finally rufus-tokyo includes ffi-based interfaces to Tokyo Dystopia (thanks to Jeremy Hinegardner).
  }
  s.email = %q{jmettraux@gmail.com}
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]
  s.files = [".gitignore", "CHANGELOG.txt", "CREDITS.txt", "LICENSE.txt", "README.rdoc", "Rakefile", "TODO.txt", "doc/decision_table.numbers", "lib/rufus-edo.rb", "lib/rufus-tokyo.rb", "lib/rufus/edo.rb", "lib/rufus/edo/README.txt", "lib/rufus/edo/cabcore.rb", "lib/rufus/edo/cabinet/abstract.rb", "lib/rufus/edo/cabinet/table.rb", "lib/rufus/edo/error.rb", "lib/rufus/edo/ntyrant.rb", "lib/rufus/edo/ntyrant/abstract.rb", "lib/rufus/edo/ntyrant/table.rb", "lib/rufus/edo/tabcore.rb", "lib/rufus/tokyo.rb", "lib/rufus/tokyo/cabinet/abstract.rb", "lib/rufus/tokyo/cabinet/lib.rb", "lib/rufus/tokyo/cabinet/table.rb", "lib/rufus/tokyo/cabinet/util.rb", "lib/rufus/tokyo/config.rb", "lib/rufus/tokyo/dystopia.rb", "lib/rufus/tokyo/dystopia/core.rb", "lib/rufus/tokyo/dystopia/lib.rb", "lib/rufus/tokyo/dystopia/words.rb", "lib/rufus/tokyo/hmethods.rb", "lib/rufus/tokyo/openable.rb", "lib/rufus/tokyo/outlen.rb", "lib/rufus/tokyo/query.rb", "lib/rufus/tokyo/transactions.rb", "lib/rufus/tokyo/ttcommons.rb", "lib/rufus/tokyo/tyrant.rb", "lib/rufus/tokyo/tyrant/abstract.rb", "lib/rufus/tokyo/tyrant/ext.rb", "lib/rufus/tokyo/tyrant/lib.rb", "lib/rufus/tokyo/tyrant/table.rb", "lib/rufus/tokyo/utils.rb", "lib/rufus/tokyo/version.rb", "rufus-tokyo.gemspec", "spec/cabinet_btree_spec.rb", "spec/cabinet_fixed_spec.rb", "spec/cabinet_spec.rb", "spec/cabinetconfig_spec.rb", "spec/dystopia_core_spec.rb", "spec/edo_cabinet_btree_spec.rb", "spec/edo_cabinet_fixed_spec.rb", "spec/edo_cabinet_spec.rb", "spec/edo_ntyrant_spec.rb", "spec/edo_ntyrant_table_spec.rb", "spec/edo_table_spec.rb", "spec/hmethods_spec.rb", "spec/incr.lua", "spec/openable_spec.rb", "spec/shared_abstract_spec.rb", "spec/shared_table_spec.rb", "spec/shared_tyrant_spec.rb", "spec/spec.rb", "spec/spec_base.rb", "spec/start_tyrants.sh", "spec/stop_tyrants.sh", "spec/table_spec.rb", "spec/tyrant_spec.rb", "spec/tyrant_table_spec.rb", "spec/util_list_spec.rb", "spec/util_map_spec.rb", "tasks/dev.rb", "test/aaron.rb", "test/bm0.rb", "test/bm1_compression.rb", "test/con0.rb", "test/jeg.rb", "test/mem.rb", "test/mem1.rb", "test/readme0.rb", "test/readme1.rb", "test/readme2.rb", "test/readme3.rb", "test/readmes_test.sh"]
  s.homepage = %q{http://github.com/jmettraux/rufus-tokyo/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rufus}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{ruby-ffi based lib to access Tokyo Cabinet, Tyrant and Dystopia}
  s.test_files = ["spec/spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<ffi>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<ffi>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

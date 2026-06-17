# frozen_string_literal: true

require 'tempfile'
require_relative '../util/code'

namespace :code do
  # NOTE, before you commit, you can check a PR for this with
  # git diff -U0 --minimal HEAD~1 | grep -v '^+#.*2024' | grep -v '^+#.*LICENSE.md' | grep -v '^+###$' | grep -v '^+#$' | grep -v '^diff --git' | grep -v '^index' | grep '^--- a' | grep '^+++ b' | more
  #
  # To review a branch vs another branch, skipping files where the only changes
  # are the copyright notice and/or frozen_string_literal, write to a diff file:
  #   branch=branch-with-changes; \
  #   target=target-branch; \
  #   git diff -w $target...$branch --name-only | while read f; do \
  #     extra=$(git diff -U0 -w $target...$branch -- "$f" | grep '^[+-]' | \
  #       grep -v '^---' | grep -v '^+++' | \
  #       grep -v '^[-+]$' | \
  #       grep -v '^[-+]###$' | \
  #       grep -v '^[-+]#$' | \
  #       grep -v '^[-+]# License detail:' | \
  #       grep -vE '^-# Copyright [0-9]{4} - [0-9]{4} Green River Data Analysis, LLC' | \
  #       grep -v '^+# Copyright Green River Data Group, Inc.' | \
  #       grep -v '^[-+]# frozen_string_literal: true'); \
  #     [ -n "$extra" ] && git diff -w $target...$branch -- "$f"; \
  #   done > tmp/changes.diff
  desc 'Ensure the copyright is included in all ruby files'
  task :maintain_copyright, [] => [:environment, 'log:info_to_stdout'] do
    puts 'Adding license text in all .rb files that don\'t already have it'
    puts ::Code.copyright_header
    @modified = 0
    files.each do |path|
      add_copyright_to_file(path)
    end

    puts "Modified #{@modified} #{'record'.pluralize(@modified)}"
  end

  def files
    Dir.glob("#{Rails.root}/app/{**/}*.rb") +
      Dir.glob("#{Rails.root}/lib/{**/}*.rb") +
      Dir.glob("#{Rails.root}/spec/{**/}*.rb") +
      Dir.glob("#{Rails.root}/config/{**/}*.rb") +
      Dir.glob("#{Rails.root}/bin/*.rb")
  end

  def add_copyright_to_file(path)
    content = File.read(path)

    # Shebang lines must stay on line 1 — extract before any other processing.
    shebang = content.slice!(/\A#![^\n]*\n/)

    return if content.start_with?(::Code.copyright_header)

    puts ">>> Updating copyright in #{path}"
    @modified += 1

    # Strip old-format header before prepending — otherwise files that already
    # have a copyright block end up with two headers stacked at the top.
    content = ::Code.strip_old_copyright(content)

    tempfile = Tempfile.new('with_copyright')
    tempfile.write(shebang) if shebang
    tempfile.write(::Code.copyright_header)
    tempfile.write(content)
    tempfile.flush
    tempfile.close
    FileUtils.cp(tempfile.path, path)
  end
end

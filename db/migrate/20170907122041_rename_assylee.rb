class RenameAssylee < ActiveRecord::Migration
  class ::Rules::Assylee < Rule
  end
  def up
    to_delete = Rules::Assylee.first
    if to_delete.present?
      to_delete.really_destroy!
      CasSeeds::Rules.new.run!
    end
  end
end

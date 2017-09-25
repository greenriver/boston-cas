class RenameRules < ActiveRecord::Migration
  def change
    Rules::OneEightyDaysHomeless.first.update(name: '180 homeless days')
    Rules::OneYearHomeless.first.update(name: '365 homeless days')
  end
end

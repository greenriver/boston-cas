class AddParkedClientsReport < ActiveRecord::Migration[6.0]
  def change
    Rake::Task["db:seed"].invoke
  end
end

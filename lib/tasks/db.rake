namespace :db do
  namespace :schema do
    desc "Conditionally load the database schema"
    task :conditional_load, [] => [:environment] do |t, args|
      if ActiveRecord::Base.connection.tables.length == 0
        Rake::Task['db:schema:load'].invoke
      else
        puts "Refusing to load the database schema since there are tables present. This is not an error."
      end
    end
  end
end

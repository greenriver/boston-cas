namespace :test do
  desc 'Test generating an Exception'
  task :exception, [] => [:environment] do |_t, _args|
    raise StandardError.new('An Exception has been raised from within a Rake task.')
  end

  desc 'Test Sentry'
  task :sentry, [] => [:environment] do |_t, _args|
    msg = "Testing Sentry from #{Rails.env} for hmis-warehouse"
    exception = StandardError.new(msg)
    Sentry.capture_exception(exception)
    Sentry.capture_message(msg)
  end
end

require "./server"
require "sinatra/activerecord/rake"
require_relative "lib/processor"

namespace :utils do

  desc "qualify photo"
  task :photo_processor do
    Processor.new.process
  end

  desc "create photo queue between webserver and processor"
  task :create_queue do
    ImageQueue.new
  end


end
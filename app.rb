require 'active_record'
# require 'sqlite3'
# require 'pg'
require 'logger'
include ActiveRecord::Tasks

root = File.expand_path '..', __FILE__
ActiveRecord::Base.logger = Logger.new('debug.log')
# configuration = YAML::load(IO.read('config/database.yml'))
# ActiveRecord::Base.establish_connection(configuration['development'])
DatabaseTasks.env = ENV['DATABASE_URL'] || 'development'
DatabaseTasks.database_configuration = YAML.load(File.read(File.join(root, 'config/database.yml')))
ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
# ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

# class User < ActiveRecord::Base
# end
# class Game < ActiveRecord::Base
# end
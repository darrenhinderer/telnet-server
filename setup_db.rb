require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter   => "sqlite3",
  :database => "telnet.db"
)


# setup account table
ActiveRecord::Schema.define do
  create_table :accounts,    :force => true do |t|
    t.column :username,       :string
    t.column :password,       :string
  end
end


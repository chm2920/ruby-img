class Admin < ActiveRecord::Base
  attr_accessible :level, :password, :adminname
end

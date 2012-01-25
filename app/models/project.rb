class Project < ActiveRecord::Base
validates :name,  :presence => true
 belongs_to :user, :class_name => "User"
 has_many :nodes, :class_name => "Node", :dependent => :destroy
 has_many :vehicles, :class_name => "Vehicle", :dependent => :destroy
end

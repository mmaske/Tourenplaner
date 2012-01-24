class Node < ActiveRecord::Base
acts_as_gmappable :process_geocoding => true, :validation =>true
  def gmaps4rails_address
  "#{self.street}, #{self.city}, #{self.country}"
  end
  belongs_to :project, :class_name => "Project"
end

# Primary Author: Jonathan Allen (jallen01)
class LocationTag < ActiveRecord::Base

  # Attributes
  # ----------

  belongs_to :location
  belongs_to :tag
  
end
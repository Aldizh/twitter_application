class Location < ActiveRecord::Base

  ################################
  #  DO NOT MODIFY THIS SECTION  #
  ################################

  
  # Validations
  validates :name, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  
  ############################################
  #  TODO: you may optionally add code here  #
  ############################################
  has_many :follow
  has_many :posts, :through => :users
  has_many :users, :through => :follow
  def to_hash
    {
      :id => self.id,
      :name => self.name,
      :latitude => self.latitude,
      :longitude => self.longitude
    }
  end

end

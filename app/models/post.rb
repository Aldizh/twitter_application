class Post < ActiveRecord::Base

  ################################
  #  DO NOT MODIFY THIS SECTION  #
  ################################

  
  # Validations
  validates :user_id, :presence => true
  validates :location_id, :presence => true
  validates :text, :presence => true
  attr_accessible :location_id, :user_id, :text
  ############################################
  #  TODO: you may optionally add code here  #
  ############################################
  belongs_to :user
  belongs_to :location
  def to_hash
    {
      :id => self.id,
      :user_id => self.user_id,
      :location_id => self.location_id,
      :text => self.text,
    }
  end

end

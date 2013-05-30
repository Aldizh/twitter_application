class Follow < ActiveRecord::Base
  validates :user_id, :presence => true
  validates :location_id, :presence => true
  validates :user_id, :uniqueness => { :scope => :location_id}
  belongs_to :user
  belongs_to :location
  def to_hash
  {
      :id => self.id,
      :user_id => self.user_id,
      :location_id => self.location_id
  }
  end
end

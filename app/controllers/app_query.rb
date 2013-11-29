class AppQuery

  ################################
  #  DO NOT MODIFY THIS SECTION  #
  ################################

  attr_accessor :posts
  attr_accessor :user
  attr_accessor :following_locations
  attr_accessor :location

  ###########################################
  #  TODO: Implement the following methods  #
  ###########################################

  # Purpose: Show all the locations being followed by the current user
  # Input:
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @following_locations - An array of hashes of location information.
  #                          Order does not matter.
  #                          Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  # Output: None
  def get_following_locations(user_id)
   @following_locations = Follow.joins(:location).where(:user_id => user_id).select("locations.id, name, latitude, longitude")
  end

  # Purpose: Show the information and all posts for a given location
  # Input:
  #   location_id - The id of the location for which to show the information and posts
  # Assign: assign the following variables
  #   @location - A hash of the given location. The hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #   @posts - An array of hashes of post information, for the given location.
  #            Reverse chronological order by creation time (newest post first).
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_posts_for_location(location_id)
    @location = Location.find_by_id(location_id)
    posts_per_location = []
    num = 0
    posts = Post.where(:location_id => location_id).order("created_at DESC")
  	posts.each do |entry|
	    name = User.find(entry[:user_id])[:name]
	    posts_per_location[num] = {:author_id => entry[:user_id], :author => name, :text => entry[:text], :created_at => entry[:created_at], :location => @location}
	    num+=1
 	  end
    @posts = posts_per_location
  end

  # Purpose: Show the current user's stream of posts from all the locations the user follows
  # Input:
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @posts - An array of hashes of post information from all locations the current user follows.
  #            Reverse chronological order by creation time (newest post first).
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_stream_for_user(user_id)
    user_posts = []
    num = 0
    posts = Post.where(:location_id => Follow.joins(:location).where(:user_id => user_id).select("location_id")).order("created_at DESC")
  	posts.each do |entry|
		  name = User.find(entry[:user_id])[:name]
		  user_posts[num] = {:author_id => entry[:user_id], :author => name, :text => entry[:text], :created_at => entry[:created_at], :location => Location.find(entry[:location_id])}
	    num+=1
    end
    @posts = user_posts || []
  end

  # Purpose: Retrieve the locations within a GPS bounding box
  # Input:
  #   nelat - latitude of the north-east corner of the bounding box
  #   nelng - longitude of the north-east corner of the bounding box
  #   swlat - latitude of the south-west corner of the bounding box
  #   swlng - longitude of the south-west corner of the bounding box
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @locations - An array of hashes of location information, which lie within the bounding box specified by the input.
  #                In increasing latitude order.
  #                At most 50 locations.
  #                Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #     * :follows - true if the current user follows this location. false otherwise.
  # Output: None
  def get_nearby_locations(nelat, nelng, swlat, swlng, user_id)
   # @locations = ActiveRecord::Base.connection.execute("SELECT * FROM locations L WHERE L.latitude BETWEEN " +swlat + "AND " + nelat +"AND L.longitude BETWEEN "+swlng +"AND "+nelng+ "LIMIT 5 ORDER BY L.latitude ASC")
    locs = Location.where(:latitude => swlat.to_f..nelat.to_f, :longitude => swlng.to_f..nelng.to_f).order("latitude ASC").limit(50)
    num = 0
    locations = []
    if not locs or locs.empty?
    	locs = []
    else
    	locs.each do |entry|
        	followed = Follow.where(:location_id => entry[:id], :user_id => user_id)
		      locations[num] = {:id => entry[:id], :name => entry[:name], :latitude => entry[:latitude], :longitude => entry[:longitude], :follows => false}
        	if(not followed.empty?)
        	  locations[num][:follows] = true
        	end
       	 num+=1
         end
    end
    @locations = locations
  end 

  # Purpose: Create a new location
  # Input:
  #   location_hash - A hash of the new location information.
  #                  The hash MAY include:
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: None
  # Output: true if the creation is successful, false otherwise
  def create_location(location_hash={})
    @location = Location.new(location_hash)
    @location.save
  end

  # Purpose: The current user follows a location
  # Input:
  #   user_id - the user id of the current user
  #   location_id - The id of the location the current user should follow
  # Assign: None
  # Output: None
  # NOTE: Although the UI will never call this method multiple times,
  #       we may call it multiple times to test your schema/models.
  #       Your schema/models/code should prevent corruption of the database.
  def follow_location(user_id, location_id)
    follow_hash = {:user_id => user_id, :location_id => location_id}
    @follow = Follow.new(follow_hash)
    @follow.save
  end

  # Purpose: The current user unfollows a location
  # Input:
  #   user_id - the user id of the current user
  #   location_id - The id of the location the current user should unfollow
  # Assign: None
  # Output: None
  # NOTE: Although the UI will never call this method multiple times,
  #       we may call it multiple times to test your schema/models.
  #       Your schema/models/code should prevent corruption of the database.
  def unfollow_location(user_id, location_id)
     @follow = Follow.where(:user_id => user_id, :location_id => location_id)
 		 @follow[0].destroy rescue nil
  end

  # Purpose: The current user creates a post to a given location
  # Input:
  #   user_id - the user id of the current user
  #   post_hash - A hash of the new post information.
  #               The hash may include:
  #     * :location_id - the id of the location
  #     * :text - the text of the posts
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: None
  # Output: true if the creation is successful, false otherwise
  def create_post(user_id, post_hash={})
    new_hash = {:user_id => user_id}
    post_hash = new_hash.merge(post_hash)
    @post = Post.new(post_hash)
    @post.save
  end

  # Purpose: Create a new user
  # Input:
  #   user_hash - A hash of the new post information.
  #               The hash may include:
  #     * :name - name of the new user
  #     * :email - email of the new user
  #     * :password - password of the new user
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: assign the following variables
  #   @user - the new user object
  # Output: true if the creation is successful, false otherwise
  # NOTE: This method is already implemented, but you are allowed to modify it if needed.
  def create_user(user_hash={})
    @user = User.new(user_hash)
    @user.save
  end

  # Purpose: Get all the posts
  # Input: None
  # Assign: assign the following variables
  #   @posts - An array of hashes of post information.
  #            Order does not matter.
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_all_posts
    @posts = Post.all
  end

  # Purpose: Get all the users
  # Input: None
  # Assign: assign the following variables
  #   @users - An array of hashes of user information.
  #            Order does not matter.
  #            Each hash should include:
  #     * :id - id of the user
  #     * :name - name of the user
  #     * :email - email of th user
  # Output: None
  def get_all_users
    @users = User.all
  end

  # Purpose: Get all the locations
  # Input: None
  # Assign: assign the following variables
  #   @locations - An array of hashes of location information.
  #                Order does not matter.
  #                Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  # Output: None
  def get_all_locations
    @locations = Location.all
  end

  # Retrieve the top 5 users who created the most posts.
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the user
  #   * num_posts - number of posts the user has created
  def top_users_posts_sql
    "SELECT name, COUNT(P.user_id) AS num_posts FROM users U, posts P WHERE U.id = P.user_id GROUP BY name HAVING num_posts > 0 ORDER BY num_posts DESC LIMIT 5"
  end

  # Retrieve the top 5 locations with the most unique posters. Only retrieve locations with at least 2 unique posters.
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the location
  #   * num_users - number of unique users who have posted to the location
  def top_locations_unique_users_sql
    "SELECT name, COUNT(DISTINCT P.user_id) AS num_users FROM locations L, posts P WHERE L.id = P.location_id GROUP BY name HAVING num_users > 1 ORDER BY num_users DESC LIMIT 5"
  end

  # Retrieve the top 5 users who follow the most locations, where each location has at least 2 posts
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the user
  #   * num_locations - number of locations (has at least 2 posts) the user follows
  def top_users_locations_sql
    "SELECT name, COUNT(F.user_id) AS num_locations FROM follows F, users U WHERE U.id = F.user_id AND EXISTS (SELECT P.location_id, COUNT(P.location_id) AS num_posts FROM locations L, posts P WHERE L.id = P.location_id AND F.location_id = P.location_id GROUP BY P.location_id HAVING num_posts > 1) GROUP BY name HAVING num_locations > 0 ORDER BY num_locations DESC LIMIT 5"
  end

end

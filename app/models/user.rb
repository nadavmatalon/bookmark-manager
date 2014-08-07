require "data_mapper"
require "bcrypt"

class User

	include DataMapper::Resource
	
	property :id, Serial

	property :email, String, required: true, unique: true, format: :email_address,
    		 				 messages: {
      							presence: "Sorry, email is required",
      							is_unique: "Sorry, this email is already taken",
      							format: "Sorry, email is not formatted correctly"
    						}

	property :password_digest, Text

	attr_reader :password
	attr_accessor :password_confirmation

	validates_uniqueness_of :email 

	validates_length_of :password, min: 6

	validates_confirmation_of :password
	
	def password=(password)
		@password = password
		self.password_digest = BCrypt::Password.create(password)
	end

	def self.authenticate(email, password)
		user = first(:email => email)
		if user && BCrypt::Password.new(user.password_digest) == password
			user
		else
			nil
		end
	end
end


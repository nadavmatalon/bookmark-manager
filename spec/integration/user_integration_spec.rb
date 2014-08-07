describe "User" do

	it 'can be created and saved in the database' do
		expect(User.count).to eq(0)
		User.create(email: "user@example.com", password: "password", password_confirmation: "password")
		expect(User.count).to eq(1)
	end

	it 'do not have their passowrd saved in the database' do
		User.create(email: "user@example.com", password: "password", password_confirmation: "password")
		user = User.first
		expect(user.password).to eq nil
	end

	it 'have their passowrd saved in the database as an encrypted hash' do
		user = User.create(email: "user@example.com", password: "password", password_confirmation: "password")
		digest = User.authenticate("user@example.com", "password").password_digest.to_s
		expect(user.password_digest.to_s).to eq digest
	end

	it 'can be retrieved from he database' do
		user = User.create(email: "user@example.com", password: "password", password_confirmation: "password")
		expect(user.email).to eq "user@example.com"
	end

	it 'can be removed from the database' do
		user = User.create(email: "user@example.com", password: "password", password_confirmation: "password")
		user.destroy
		expect(User.count).to eq 0
	end		
end

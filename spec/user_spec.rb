require "spec_helper.rb"

feature "User" do

	scenario "can sign up" do
		lambda { sign_up }.should change(User, :count).by(1)
		expect(page).to have_content ("Welcome test@example.com")
		expect(User.first.email).to eq ("test@example.com")
	end

	scenario "cannot sign up with a password that doesn\'t match" do
		lambda { sign_up('test@example.com', 'password_a', 'password_b') }.should change(User, :count).by(0) 
		expect(current_path).to eq('/users')
		expect(page).to have_content("Password does not match the confirmation")
	end

	scenario "cannot sign up with a password that is less than 6 chars" do
		lambda { sign_up('test@example.com', 'pass', 'pass') }.should change(User, :count).by(0) 
		expect(current_path).to eq('/users')
		expect(page).to have_content("Password must be at least 6 characters long")
	end

	scenario "cannot sign up with an email that\'s not correctly formatted" do
		lambda { sign_up('test', 'password', 'password') }.should change(User, :count).by(0) 
		expect(page).to have_content("Sorry, email is not formatted correctly")
	end

	scenario "cannot sign up with an email that\'s already taken" do
		register_user
		lambda { sign_up }.should change(User, :count).by(0)
		expect(page).to have_content("Sorry, this email is already taken")
	end

	scenario "can sign in with correct credentials" do
		register_user
		sign_in
		expect(page).to have_content("Welcome test@example.com")
	end

	scenario "cannot sign in with incorrect email" do
		register_user
		sign_in("wrong@example.com", "password")
		expect(page).to have_content("email or password are incorrect")
	end

	scenario "cannot sign in with incorrect password" do
		register_user
		sign_in("test@example.com", "wrong")
		expect(page).to have_content("email or password are incorrect")
	end

	scenario "can sign out if already signed in" do
		register_user
		expect(page).to have_content("Bye for now test@example.com, thanks for visiting!")
		expect(page).not_to have_content("Welcome test@example.com")
	end
end


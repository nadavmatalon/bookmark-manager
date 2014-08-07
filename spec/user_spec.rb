require "spec_helper.rb"

feature "User" do

	scenario "can sign up" do
		lambda { sign_up }.should change(User, :count).by(1)
		expect(page).to have_content ("Welcome test@example.com")
		expect(User.first.email).to eq ("test@example.com")
	end

	scenario "cannot sign up with a password that doesn\'t match" do
		lambda { sign_up('test@example.com', 'right', 'wrong') }.should change(User, :count).by(0) 
		expect(current_path).to eq('/users')
		expect(page).to have_content("Password does not match the confirmation")
	end

	scenario "cannot sign up with an email that\'s already taken" do
		register_user
		lambda { sign_up }.should change(User, :count).by(0)
		expect(page).to have_content("This email is already taken")
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


def register_user
	sign_up
	sign_out
end

def sign_up(email = "test@example.com", password = "password", 
			password_confirmation = "password")
	visit "/"
	click_link "Sign up"
	fill_in :email, with: email
	fill_in :password, with: password
	fill_in :password_confirmation, with: password_confirmation
	click_button "Register"
end

def sign_in(email = "test@example.com", password = "password")
	visit "/sessions/new"
	fill_in "email", with: email
	fill_in "password", with: password
	click_button "Sign In"
end

def sign_out
	visit "/"
	click_button "Sign out"
end


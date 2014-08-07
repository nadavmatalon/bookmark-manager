feature "User" do

	scenario "can sign up" do
		sign_up
		expect(User.count).to eq 1
		expect(page).to have_content ("Welcome test@example.com")
		expect(User.first.email).to eq ("test@example.com")
	end

	scenario "is re-directed to the homepage after sign up" do
		sign_up
		expect(current_path).to eq('/')
		expect(page).to have_button "Sign out"
		expect(page).not_to have_button "Sign up"
		expect(page).not_to have_button "Sign in"
	end

	scenario "has the option to sign out after signing up" do
		sign_up
		expect(page).to have_button "Sign out"
		expect(page).not_to have_button "Sign up"
		expect(page).not_to have_button "Sign in"
	end

	scenario "does not have the option to sign up or sign in after signing up" do
		sign_up
		expect(page).not_to have_button "Sign up"
		expect(page).not_to have_button "Sign in"
	end

	scenario "cannot sign up with a password that doesn\'t match" do
		sign_up('test@example.com', 'password_a', 'password_b')
		expect(User.count).to eq 0
		expect(page).not_to have_button "Sign out"
	end

	scenario "is shown the correct error message if password doesn\'t match on sign up" do
		sign_up('test@example.com', 'password_a', 'password_b')
		expect(page).to have_content "Password does not match the confirmation"
	end

	scenario "cannot sign up with a password that is less than 6 chars" do
		sign_up('test@example.com', 'pass', 'pass')
		expect(User.count).to eq 0
	end

	scenario "is shown the correct error message if password is less than 6 chars on sign up" do
		sign_up('test@example.com', 'pass', 'pass')
		expect(page).to have_content "Password must be at least 6 characters long"
	end

	scenario "cannot sign up with an email that\'s not correctly formatted" do
		sign_up('test', 'password', 'password')
		expect(User.count).to eq 0
	end

	scenario "is shown the correct error message if email is not correctly formatted on sign up" do
		sign_up('test', 'password', 'password')
		expect(page).to have_content "Sorry, email is not formatted correctly"
	end

	scenario "cannot sign up with an email that\'s already taken" do
		register_user
		expect(User.count).to eq 1
		sign_up
		expect(User.count).to eq 1
	end

	scenario "is shown the correct error message if email is already taken on sign up" do
		register_user
		sign_up
		expect(page).to have_content("Sorry, this email is already taken")
	end

	scenario "remains on sign up page on unsuccessful sign up" do
		sign_up('test', 'pass', 'pass')
		expect(current_path).to eq('/users')
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
		sign_in
		click_button "Sign out"
		expect(page).not_to have_content("Welcome test@example.com")
	end

	scenario "is shown the correct message when signing out" do
		register_user
		sign_in
		sign_out
		expect(page).to have_content("Bye for now test@example.com, thanks for visiting!")
	end

	scenario "cannot sign out if already signed out" do
		register_user
		sign_in
		sign_out
		expect(page).not_to have_button "Sign out"
		expect(page).to have_content("Welcome Guest")
	end
end


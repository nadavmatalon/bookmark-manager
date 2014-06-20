

feature "User:" do

	scenario "can sign up" do
		lambda { sign_up }.should change(User, :count).by(1)
		expect(page).to have_content ("Welcome alice@example.com")
		expect(User.first.email).to eq ("alice@example.com")
	end

	scenario "cannot register with a password that doesn't match" do
		lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0) 
		expect(current_path).to eq('/users')
		expect(page).to have_content("Password does not match the confirmation")
	end

	scenario "with an email that is already registered" do
		lambda { sign_up }.should change(User, :count).by(1)
		lambda { sign_up }.should change(User, :count).by(0)
		expect(page).to have_content("This email is already taken")
	end

	def sign_up(email = "alice@example.com", password = "apple", password_confirmation = "apple")
		visit "/new_user"
		expect(page.status_code).to eq(200)
		fill_in :email, :with => email
		fill_in :password, :with => password
		fill_in :password_confirmation, :with => password_confirmation
		click_button "Register"
  end

end

feature "User signs in" do

	before(:each) do

		User.create(:email => "test@test.com", :password => "test",
					:password_confirmation => "test")
	end

	scenario "with correct credentials" do
		visit "/"
		expect(page).not_to have_content("Welcome test@test.com")
		sign_in("test@test.com", "test")
		expect(page).to have_content("Welcome test@test.com")
	end

	scenario "with incorrect credentials" do
		visit "/"
		expect(page).not_to have_content("Welcome test@test.com")
		sign_in("test@test.com", "wrong")
		expect(page).not_to have_content("Welcome test@test.com")
	end

	def sign_in(email, password)
		visit "/user_sign_in"
		fill_in "email", :with => email
		fill_in "password", :with => password
		click_button "Sign In"
	end

end


feature "User signs out" do

	before(:each) do
		User.create(:email => "test@test.com", :password => "test",
					:password_confirmation => "test")
	end

	scenario "while being signed in" do
		sign_in("test@test.com", "test")
		click_button "Sign out"
		expect(page).to have_content("Good bye!")
		expect(page).not_to have_content("Welcome test@test.com")
	end

	def sign_in(email, password)
		visit "/user_sign_in"
		fill_in "email", :with => email
		fill_in "password", :with => password
		click_button "Sign In"
	end

end




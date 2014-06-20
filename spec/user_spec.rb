require_relative "spec_helper.rb"
# require "./spec/spec_helper.rb"

feature "User:" do

	scenario "can sign up" do

		lambda { sign_up }.should change(User, :count).by(1)
		expect(page).to have_content ("Welcome alice@example.com")
		expect(User.first.email).to eq ("alice@example.com")
	end

	scenario "cannot register with a password that doesn't match" do
		lambda { sign_up("a@a.com", "pass", "wrong") }.should change(User, :count).by(0)
	end

	def sign_up(email = "alice@example.com", password = "apple", password_confirmation = "apple")
		visit '/new_user'
		fill_in :email, :with => email
		fill_in :password, :with => password
		fill_in :password_confirmation, :with => password_confirmation
		click_button "Register"
  end


	# def sign_up(email = "alice@example.com", password = "oranges!")
	# 	visit "/new_user"
	# 	expect(page.status_code).to eq(200)
	# 	expect(page.status_code).to eq(200)
	# 	fill_in :email, :with => email
	# 	fill_in :password, :with => password
	# 	click_button "Register"
	# end
end


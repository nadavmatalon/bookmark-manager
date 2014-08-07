require "spec_helper.rb"

feature "Link (aka Bookmark)" do

	before(:each) do
		sign_up
		visit '/'
	end

	scenario "initially the bookmark list in home page is empty" do
		expect(page).to have_content "No bookmarks yet"
	end

	scenario "can be added by user if signed in" do
		add_link("http//:www.google.com", "Example_title", "Search")
		expect(page).to have_content "Example_title"
	end

	scenario "cannot be added by user if not signed in" do
		sign_out
		expect(page).not_to have_css '#new-link'
		expect(page).not_to have_button 'Add link'
	end

	scenario "will have it\'s title capitalized when saved" do
		add_link("http//:www.google.com", "google", "Search")
		expect(page).to have_content "Google"
	end

	scenario "list shows all saved bookmarks" do
		add_link("http//:www.google.com", "Google", "Search")
		add_link("http//:www.yahoo.com", "Yahoo", "Search")
		add_link("http/:www.amazon.com", "Amazon", "Books")
		expect(page).to have_content "Google"
		expect(page).to have_content "Yahoo"
		expect(page).to have_content "Amazon"
	end

	scenario "list can be filtered according to tags" do
		add_link("http//:www.google.com", "Google", "Search")
		add_link("http/:www.amazon.com", "Amazon", "Books")
		click_link "Search"
		expect(page).to have_content "Google"
		expect(page).to have_content "Bookmarks with Search tag:"
		expect(page).to have_link "Show all"
		expect(page).not_to have_content "Amazon"
		expect(page).not_to have_content "Books"
	end

	scenario "list shows bookmarks alphabetically according to title" do
		add_link("http//:www.yahoo.com", "Yahoo", "Search")
		add_link("http/:www.amazon.com", "Amazon", "Books")
		add_link("http//:www.google.com", "Google", "Search")
		expect(page).not_to have_content "Yahoo Search Amazon Books Google Search"
		expect(page).to have_content "Amazon Books Google Search Yahoo Search"
	end
end



feature "Tag" do
	
	it 'is capitalized when added to a new bookmark' do
		sign_up
		visit '/'
		add_link("http//:www.google.com", "Google", "search")
		expect(page).to have_content "Search"
	end

	it 'will be sorted alphabetically under each bookmark' do
		sign_up
		visit '/'
		add_link("http//:www.google.com", "Google", "Search")
		add_link("http/:www.amazon.com", "Amazon", "Books")
		expect(page).not_to have_content "Google Search Amazon Books"
		expect(page).to have_content "Amazon Books Google Search"
	end
end


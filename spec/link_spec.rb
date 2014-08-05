
describe Link do

	context "Demonstration of how datamapper works" do

		it 'should be created and then retrieved from the db' do
			expect(Link.count).to eq(0)
			Link.create(:title => "Makers Academy", :url => "http://www.makersacademy.com/")
			expect(Link.count).to eq(1)
			link = Link.first
			expect(link.url).to eq("http://www.makersacademy.com/")
			expect(link.title).to eq("Makers Academy")
			link.destroy
			expect(Link.count).to eq(0)
		end		
	end
end

feature "User browses the list of links" do

	before(:each) {
		Link.create(:url => "http://www.makersacademy.com", :title => "Makers Academy",
					:tags => [Tag.first_or_create(:text => 'education')])
	}

	scenario "when opening the home page" do
		visit '/'
		expect(page).to have_content("Makers Academy")
	end
end

feature "User adds a new link" do

	scenario "when browsing the homepage" do

		expect(Link.count).to eq(0)
		visit '/'
		add_link("http://www.makersacademy.com/", "Makers Academy")
		expect(Link.count).to eq(1)
		link = Link.first
		expect(link.url).to eq("http://www.makersacademy.com/")
		expect(link.title).to eq("Makers Academy")
	end

	scenario "with a few tags" do
		visit "/"
		add_link("http://www.makersacademy.com/", "Makers Academy", ["education, ruby"])
		link = Link.first
		expect(link.tags.map(&:text)).to include("Education")
		expect(link.tags.map(&:text)).to include("Ruby")
	end
end

feature "User browses the list of links" do

	before(:each) {
		Link.create(:url => "http://www.makersacademy.com", :title => "Makers Academy",
					:tags => [Tag.first_or_create(:text => 'education')])

		Link.create(:url => "http://www.google.com", :title => "Google", 
					:tags => [Tag.first_or_create(:text => 'search')])

		Link.create(:url => "http://www.bing.com", :title => "Bing",
					:tags => [Tag.first_or_create(:text => 'search')])

		Link.create(:url => "http://www.code.org", :title => "Code.org",
					:tags => [Tag.first_or_create(:text => 'education')])
	}

	scenario "filtered by a tag" do
		visit '/tags/search'
		expect(page).not_to have_content("Makers Academy")
		expect(page).not_to have_content("Code.org")
		expect(page).to have_content("Google")
		expect(page).to have_content("Bing")
	end
end

def add_link(url, title, tags = [])
	sign_up
	visit "/"
	within('#new-link') do
		fill_in 'url', :with => url
		fill_in 'title', :with => title
		fill_in 'tags', :with => tags.join(' ')
		click_button 'Add link'
	end
end

def sign_up
	visit "/users/new"
	fill_in :email, with: "alice@example.com"
	fill_in :password, with: "apple"
	fill_in :password_confirmation, with: "apple"
	click_button "Register"
end

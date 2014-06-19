require_relative "spec_helper.rb"
# require "./spec/spec_helper.rb"

describe Link do

	context "Demonstration of how datamapper works" do

		it 'should be created and then retrieved from the db' do
			expect(Link.count).to eq(0)
			Link.create(:title => "Makers Academy", :url => "http://www.makersacademy.com/")
			expect(Link.count).to eq(1)
			link = Link.first
			# debugger
			expect(link.url).to eq("http://www.makersacademy.com/")
			expect(link.title).to eq("Makers Academy")
			link.destroy
			expect(Link.count).to eq(0)
		end		
	end
end

feature "User browses the list of links" do

	before(:each) {
		Link.create(:url => "http://www.makersacademy.com", :title => "Makers Academy")
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

	def add_link(url, title)		#this is a helper method - in practice the data
									#is entered by the users in the browser
		within('#new-link') do
			fill_in 'url', :with => url
			fill_in 'title', :with => title
			click_button 'Add link'
		end
	end
end



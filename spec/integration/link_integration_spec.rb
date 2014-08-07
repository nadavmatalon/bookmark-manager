describe "Bookmark (Link)" do

	it 'can be created and saved in the database' do
		expect(Link.count).to eq(0)
		Link.create(title: "Makers Academy", url: "http://www.makersacademy.com")
		expect(Link.count).to eq(1)
	end

	it 'can be retrieved from he database' do
		link = Link.create(title: "Makers Academy", url: "http://www.makersacademy.com")
		expect(link.url).to eq "http://www.makersacademy.com"
		expect(link.title).to eq "Makers Academy"
	end

	it 'can be removed from the database' do
		link = Link.create(title: "Makers Academy", url: "http://www.makersacademy.com")
		link.destroy
		expect(Link.count).to eq 0
	end		

	it 'can have a no tags' do
		create_link(title="title", url="http://www.example.com", tags=[])
		expect(Link.count).to eq 1
		expect(Link.first.tags.count).to eq 0
	end		
	
	it 'can have one tag' do
		create_link(title="title", url="http://www.example.com", tags=[create_tag])
		expect(Link.count).to eq 1
		expect(Link.first.tags.count).to eq 1
	end	

	it 'can have more than one tag' do
		create_link
		expect(Link.count).to eq 1
		expect(Link.first.tags.count).to eq 2
	end	
end

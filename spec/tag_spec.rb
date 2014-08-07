require "spec_helper.rb"

feature "Tag" do
	
	it 'can be created and saved in the database' do
		expect(Tag.count).to eq(0)
		create_tag("Search")
		expect(Tag.count).to eq(1)
	end

	it 'can be retrieved from he database' do
		create_tag("Search")
		expect(Tag.first.text).to eq "Search"
	end

	it 'can be removed from the database' do
		tag = create_tag("Search")
		tag.destroy
		expect(Tag.count).to eq 0
	end	

	it 'can only be saved once into the database' do
		create_tag("search")
		create_tag("search")
		expect(Tag.count).to eq 1
	end

end

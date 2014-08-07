module SessionHelpers

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
        visit "/"
        click_link "Sign in"
        fill_in "email", with: email
        fill_in "password", with: password
        click_button "Sign In"
    end

    def sign_out
        visit "/"
        click_button "Sign out"
    end

    def create_tag(text="tag")
        Tag.create(text: text)  
    end

    def create_link(url="http://www.example.com", title="title", 
                    tags=[create_tag("tag_one"), create_tag("tag_two")])
        Link.create(url: url, title: title, tags: tags)
    end

    def add_link(url, title, tags)
        within('#new-link') do
            fill_in 'url', with: url
            fill_in 'title', with: title
            fill_in 'tags', with: tags
        end 
        click_button 'Add link' 
    end
end


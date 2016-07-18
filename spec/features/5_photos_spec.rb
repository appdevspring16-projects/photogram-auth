require "rails_helper"

show_tests_in_browser = true
do_not_show_tests_in_browser = false

feature "/photos:", js: do_not_show_tests_in_browser do

  scenario "only shows edit & delete options for the current user's photos", points: 2 do
    first_user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    second_user = FactoryGirl.create(:user, :username => "bob", :email => "bob@example.com")
    first_photo = FactoryGirl.create(:photo, :user_id => first_user.id)
    second_photo = FactoryGirl.create(:photo, :user_id => second_user.id)
    login_as(second_user, :scope => :user)

    visit "/photos"

    expect(page).not_to have_link(nil, href: "/photos/#{first_photo.id}/edit")
    expect(page).not_to have_link(nil, href: "/delete_photo/#{first_photo.id}")
    expect(page).to have_link(nil, href: "/photos/#{second_photo.id}/edit")
    expect(page).to have_link(nil, href: "/delete_photo/#{second_photo.id}")
  end

  scenario "uses Bootstrap panels (.panel class)", points: 1 do
    user = FactoryGirl.create(:user)
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    expect(page).to have_css(".panel")
  end

  scenario "uses Font Awesome fa-plus icon (and does not use 'Photos' h1 tag)", points: 1 do
    user = FactoryGirl.create(:user)
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    expect(page).to have_css(".fa-plus")
    expect(page).not_to have_selector("h1", text: "Photos")
  end

  scenario "for each photo, displays username, photo, and time elapsed", points: 1, hint: "Use time_ago_in_words (see homework instructions) & add the word 'ago'." do
    first_user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    second_user = FactoryGirl.create(:user, :username => "bob", :email => "bob@example.com")
    third_user = FactoryGirl.create(:user, :username => "carol", :email => "carol@example.com")
    first_photo = FactoryGirl.create(:photo, :user_id => first_user.id)
    second_photo = FactoryGirl.create(:photo, :user_id => second_user.id, :created_at => "#{Time.now - 60 * 60}") # time in seconds, set one hour in the past
    login_as(third_user, :scope => :user)

    visit "/photos"

    expect(page).to have_content("#{first_photo.user.username}")
    expect(page).to have_css("img[src*='#{first_photo.image}']")
    expect(page).to have_content("#{second_photo.user.username}")
    expect(page).to have_css("img[src*='#{second_photo.image}']")
    expect(page).to have_content("about 1 hour ago")
  end

  scenario "header uses Font Awesome fa-sign-out icon", points: 1 do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit "/photos"

    within("nav") {
      expect(page).to have_css(".fa-sign-out")
    }
  end

  scenario "lists comments with authors", points: 1 do
    first_user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    second_user = FactoryGirl.create(:user, :username => "bob", :email => "bob@example.com")
    third_user = FactoryGirl.create(:user, :username => "carol", :email => "carol@example.com")
    first_photo = FactoryGirl.create(:photo, :user_id => third_user.id)
    second_photo = FactoryGirl.create(:photo, :user_id => third_user.id)
    first_comment = FactoryGirl.create(:comment, :user_id => first_user.id, :body => "Lorem ipsum dolor sit amet", :photo_id => first_photo.id)
    second_comment = FactoryGirl.create(:comment, :user_id => second_user.id, :body => "consectetur adipiscing elit, sed do eiusmod", :photo_id => second_photo.id)
    login_as(third_user, :scope => :user)

    visit "/photos"

    expect(page).to have_content(first_comment.body)
    expect(page).to have_content(first_comment.user.username)
    expect(page).to have_content(second_comment.body)
    expect(page).to have_content(second_comment.user.username)
  end

  scenario "shows Font Awesome heart icons to add/delete likes", points: 1, hint: "Font Awesome icon classes: fa-heart and fa-heart-o." do
    first_user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    second_user = FactoryGirl.create(:user, :username => "bob", :email => "bob@example.com")
    first_photo = FactoryGirl.create(:photo, :user_id => second_user.id)
    second_photo = FactoryGirl.create(:photo, :user_id => second_user.id)
    first_like = FactoryGirl.create(:like, :user_id => first_user.id, :photo_id => first_photo.id)
    second_like = FactoryGirl.create(:like, :user_id => second_user.id, :photo_id => second_photo.id)
    login_as(first_user, :scope => :user)

    visit "/photos"

    expect(page).to have_css(".fa-heart")
    expect(page).to have_css(".fa-heart-o")
  end

  scenario "includes form field with placeholder 'Add a comment...'", points: 1 do
    user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    expect(page).to have_selector("input[placeholder='Add a comment...']")
  end
end

feature "/photos:", js: do_not_show_tests_in_browser do

  scenario "quick-add a comment works and leads back to /photos", points: 2 do
    user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"
    fill_in "Add a comment...", with: "Lorem ipsum dolor sit amet"
    find_field("Add a comment...").native.send_keys(:return)

    form = find_by_id("photo_#{photo.id}_new_comment_form")
    Capybara::RackTest::Form.new(page.driver, form.native).submit :name => nil

    expect(page).to have_content("Lorem ipsum dolor sit amet")
    expect(page).to have_current_path("/photos")
  end

  scenario "quick-add a like works", points: 2 do
    user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    starting_count_of_likes = Like.count
    visit "/photos"
    find(".fa-heart-o").click
    ending_count_of_likes = Like.count

    expect(starting_count_of_likes).to eq(ending_count_of_likes - 1)
  end

  scenario "uses .fa-heart-o icon to add like, .fa-heart to remove like", points: 1 do
    user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    form = find_by_id("photo_#{photo.id}_like_form")
    Capybara::RackTest::Form.new(page.driver, form.native).submit :name => nil

    expect(page).to have_css(".fa-heart")
  end

  scenario "quick-delete a like works", points: 2 do
    user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    like = FactoryGirl.create(:like, :user_id => user.id, :photo_id => photo.id)
    login_as(user, :scope => :user)

    starting_count_of_likes = Like.count
    visit "/photos"
    find(".fa-heart").click
    ending_count_of_likes = Like.count

    expect(page).to have_css(".fa-heart-o")
    expect(starting_count_of_likes).to eq(ending_count_of_likes + 1)
  end

end

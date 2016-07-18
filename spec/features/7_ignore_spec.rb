# require "rails_helper"

# show_tests_in_browser = true
# do_not_show_tests_in_browser = false

# feature "/photos:", js: show_tests_in_browser do

 ## DOESN'T WORK: tests occur before final login run
  # scenario "quick-add a comment sets the author correctly", points: 1 do
  #   first_user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
  #   second_user = FactoryGirl.create(:user, :username => "bob", :email => "bob@example.com")
  #   third_user = FactoryGirl.create(:user, :username => "carol", :email => "carol@example.com")
  #   photo = FactoryGirl.create(:photo, :user_id => third_user.id)
  #   login_as(first_user, :scope => :user)

  #   visit "/photos"
  #   fill_in "Add a comment...", with: "Lorem ipsum dolor sit amet"
  #   find_field("Add a comment...").native.send_keys(:return)
  #   login_as(second_user, :scope => :user)

  #   expect(page).to have_content("Lorem ipsum dolor sit amet")
  #   expect(page).to have_content(first_user.username) # as comment author
  #   expect(page).to have_content(second_user.username) # because logged in
  #   expect(page).to have_content(third_user.username) # as photo submitter
  # end

 ## DOESN'T WORK: tests occur before final login run
 # scenario "displays usernames that like each photo", points: 1 do
 #    first_user = FactoryGirl.create(:user, :username => "alice", :email => "alice@example.com")
 #    second_user = FactoryGirl.create(:user, :username => "bob", :email => "bob@example.com")
 #    third_user = FactoryGirl.create(:user, :username => "carol", :email => "carol@example.com")
 #    photo = FactoryGirl.create(:photo, :user_id => first_user.id)
 #    login_as(second_user, :scope => :user)

 #    visit "/photos"
 #    find(".fa-heart-o").click
 #    login_as(third_user, :scope => :user)

 #    expect(page).to have_content(first_user.username) # as photo submitter
 #    expect(page).to have_content(second_user.username) # because liked photo
 #    expect(page).to have_content(third_user.username) # because logged in
 #  end

# end

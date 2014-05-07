require 'spec_helper'

describe MessagesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:room) { FactoryGirl.create(:room, :user_id => user.id ) }

  before { sign_in user
  #@message = FactoryGirl.create(:message)
  }
  it "should  save message" do
    response.should be_success
  end

  it "should not save message" do
    message = Message.new
    assert !message.save
  end

  it "should be redirect" do
    response.should_not be_redirect
  end
  it "has a 200 status code" do
    expect(response.status).to eq(200)
  end

  it "message create" do
    expect {
      post :create, :messages => FactoryGirl.create(:message).attributes, :user_id => user
    }.to change(Message, :count).by(1)
    end

  it "message create" do
      get :search, :body => "a"
  end

  #it "message create" do
  #
  #  get :message_params, :message => FactoryGirl.create(:message, :user_id => user.id).attributes
  #
  #end
  #it "should return the same value" do
  #  messages = FactoryGirl.create(:message)
  #
  #  expect(messages).to eq(messages)
  #end
end
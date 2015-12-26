
require "spec_helper"
require "ostruct"

RSpec.describe GeekItem do

  it "requires user_id" do
    expect(GeekItem.new user_id: nil, item_id: "-1" ).not_to be_valid
    expect(GeekItem.new user_id: "89ABC", item_id: "1asd" ).to be_valid
  end

  it "requires item_id" do
    expect(GeekItem.new user_id: "1234", item_id: nil ).not_to be_valid
    expect(GeekItem.new user_id: "99999999999999999999", item_id: "#########################" ).to be_valid
  end

  it "can be saved" do
    item = GeekItem.new user_id: "abc", item_id: "!@\#$"

    expect(item.save ).to be true
  end

  it "can be retrieved" do
    item = GeekItem.create user_id: "123", item_id: "xyz"
    found = GeekItem.find item.id
    expect(found.user_id ).to eq "123"
    expect(found.item_id ).to eq "xyz"

  end



end

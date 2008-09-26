# Steps for the multiple_find story.

steps_for (:multiple_find) do

  Given "a connection to the Alumni DND server" do 
    connect_alum!
  end

  When "performing a find for user '$user'" do |look_for|
    find!(look_for)
  end

  Then "it closes the connection" do
    close!
  end

  Then "it returns an Array with '$num' items" do |num|
    @profiles.should have(num.to_i).items
  end

  Then "the last element of the array is a Profile" do 
    @profiles[-1].should be_an_instance_of(Net::DND::Profile)
  end

  Then "the '$attrib' attribute of the last element is '$value'" do |attrib, value|
    @profiles[-1][attrib].should == value
  end

end

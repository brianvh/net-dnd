# Single_find step group, but some of these steps are used in other stories.

steps_for (:single_find) do
  Given("a DND connection to '$host' with fields '$fields'") do |host, fields|
    connect!(host, fields)
  end

  When "performing a find for user '$user' with a one of '$one'" do |look_for, one|
    find!(look_for, one)
  end

  Then "it closes the connection" do
    close!
  end

  Then "it returns a single profile object" do
    @profile.should be_an_instance_of(Net::DND::Profile)
  end

  Then "it should have the name '$name'" do |name|
    @profile.name.should == name
  end

  Then "it should have the uid '$uid'" do |uid|
    @profile.uid.should == uid
  end

  Then "it should have the dctsnum '$did'" do |did|
    @profile.dctsnum.should == did
  end

  Then "it returns a nil result" do
    @profile.should be_nil
  end
end

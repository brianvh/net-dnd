steps_for (:finding) do

  Given 'Net::DND connection to "$host" with "$field_list"' do |host, field_list|
    connect! host, field_list
  end

end

def connect!(host, field_list)
  puts host
  puts field_list.inspect
end
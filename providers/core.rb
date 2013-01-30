action :add do
  status_url = "http://127.0.0.1:8080/#{new_resource.app}/admin/cores?action=STATUS&core=#{new_resource.name}&wt=json"

  status_response = Net::HTTP.get_response(URI.parse(status_url))
  status = JSON.parse(status_response.body)

  if status['status'][new_resource.name].has_key?('dataDir') === false then
    create_url = "http://127.0.0.1:8080/#{new_resource.app}/admin/cores?action=CREATE&name=#{new_resource.name}&instanceDir=typo3cores&schema=#{new_resource.language}/schema.xml&dataDir=data/#{new_resource.name}"

    Net::HTTP.get_response(URI.parse(create_url))
  end

  new_resource.updated_by_last_action(true)
end

action :remove do
  delete_url = "http://127.0.0.1:8080/#{new_resource.app}/admin/cores?action=UNLOAD&core=#{new_resource.name}&deleteIndex=true"
  Net::HTTP.get_response(URI.parse(delete_url))
end
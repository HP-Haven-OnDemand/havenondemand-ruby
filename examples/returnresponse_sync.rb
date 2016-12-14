require_relative "../lib/havenondemand.rb"

$client = HODClient.new("YOUR_API_KEY", "v1")

params = {}
params["text"] = "Haven OnDemand is awesome"
params["language"] = 'eng'
hodApp = 'analyzesentiment'
# get_request with return response in synchronous mode
r = $client.get_request(hodApp, params, false, nil)

# post_request with return response in synchronous mode
#r = $client.post_request(hodApp, params, false, nil)

puts r

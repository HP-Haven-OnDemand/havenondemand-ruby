require_relative "../lib/havenondemand.rb"

$client = HODClient.new("YOUR_API_KEY", "v1")
$parser = HODResponseParser.new()


params = {}
params["text"] = "Haven OnDemand is awesome"
params["language"] = 'eng'
hodApp = 'analyzesentiment'
# get_request with return response in asynchronous mode
r = $client.get_request(hodApp, params, true, nil)
jobID = $parser.parse_jobid(r)
r = $client.get_job_result(jobID)

# post_request with return response in asynchronous mode
=begin
r = $client.post_request(hodApp, params, true, nil)
jobID = $parser.parse_jobid(r)
r = $client.get_job_result(jobID)
=end

puts r

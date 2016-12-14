**Note:** use `iod` branch for older compatibility syntax.  

# Ruby gem for Haven OnDemand
Official Ruby gem to help with calling Haven OnDemand APIs [http://havenondemand.com](http://havenondemand.com). Gem is hosted on rubygems.org [here](https://rubygems.org/gems/havenondemand).

## What is Haven OnDemand?
Haven OnDemand is a set of over 70 APIs for handling all sorts of unstructured data. Here are just some of our APIs' capabilities:
* Speech to text
* OCR
* Text extraction
* Indexing documents
* Smart search
* Language identification
* Concept extraction
* Sentiment analysis
* Web crawlers
* Machine learning

For a full list of all the APIs and to try them out, check out https://www.havenondemand.com/developer/apis


## Installation

To install from rubygems.org.

```
gem install havenondemand
```

To install the latest version from this github repo, use the specific_install gem.

```
gem install specific_install
gem specific_install https://github.com/HP-Haven-OnDemand/havenondemand-ruby
```


## Usage


### Importing
When using rails and other frameworks with a gem file, include it in it.
```ruby
gem "havenondemand"
```
Or, require it directly in your app.
```ruby
require "havenondemand"
```

###Initializing the client
```ruby
client = HODClient.new(apikey, version)
```
You can find your API key [here](https://www.haveondemand.com/account/api-keys.html) after signing up.

`version` is an optional parameter (defaults to `'v1'`) and can be either `'v1'` or `'v2'`.

## Sending requests to the API - POST and GET
You can send requests to the API with either a POST or GET request, where POST requests are required for uploading files and recommended for larger size queries and GET requests are recommended for smaller size queries.

### POST request
```ruby
client.get_request(hodApp, params, async, method(:callback))
```
* `hodApp` is the name of the API you are calling (see this [list]() for available endpoints and our [documentation](https://dev.havenondemand.com/apis) for descriptions of each of the APIs)
* `params` is a dictionary of parameters passed to the API
* `async` specifies if you are calling the API asynchronously or synchronously, which is either `true` or `false`, respectively
* `callback` which is a callback function which is executed when the response from the API is received. Specify 'nil' for returning response.

### GET request
```ruby
client.get_request(hodApp, params, async, method(:callback))
```
* `hodApp` is the name of the API you are calling (see this [list]() for available endpoints and our [documentation](https://dev.havenondemand.com/apis) for descriptions of each of the APIs)
* `params` is a dictionary of parameters passed to the API
* `async` specifies if you are calling the API asynchronously or synchronously, which is either `true` or `false`, respectively
* `callback` which is a callback function which is executed when the response from the API is received. Specify 'nil' for returning response.

### POST request for combinations
```ruby
client.post_request_combination(hodApp, params, async, method(:callback))
```
* `hodApp` is the name of the combination API you are calling
* `params` is a dictionary of parameters passed to the API
* `async` specifies if you are calling the API asynchronously or synchronously, which is either `true` or `false`, respectively
* `callback` which is a callback function which is executed when the response from the API is received. Specify 'nil' for returning response.


### GET request for combinations
```ruby
client.get_request_combination(hodApp, params, async, method(:callback))
```
* `hodApp` is the name of the combination API you are calling
* `params` is a dictionary of parameters passed to the API
* `async` specifies if you are calling the API asynchronously or synchronously, which is either `true` or `false`, respectively
* `callback` which is a callback function which is executed when the response from the API is received. Specify 'nil' for returning response.

## Synchronous vs Asynchronous
Haven OnDemand's API can be called either synchronously or asynchronously. Users are encouraged to call asynchronously if they are POSTing large files that may require a lot of time to process. If not, calling them synchronously should suffice. For more information on the two, see [here](https://dev.havenondemand.com/docs/AsynchronousAPI.htm).

### Synchronous
To make a synchronous GET request to our Sentiment Analysis API

```ruby
params = {:text=> 'I love Haven OnDemand!'}
hodApp = "analyzesentiment"
response = client.get_request(hodApp, params, false, nil)
```
where the response will be in the `response` variable.

### Asynchronous
To make an asynchronous POST request to our Sentiment Analysis API

```ruby
params = {:text=> 'I love Haven OnDemand!'}
hodApp = "analyzesentiment"
response_async = post_request(hodApp, params, async=true, nil)
jobID = response_async['jobID']
```
which will return back the job ID of your call. Use the job ID to call the get_job_status() or get_job_result() to get the result.

#### Getting the results of an asynchronous request - Status API and Result API

##### Status API
The Status API checks to see the status of your job request. If it is finished processing, it will return the result. If not, it will return you the status of the job.

```ruby
client.get_job_status(jobID, method(:callback))
```
* `jobID` is the job ID of request returned after performing an asynchronous request
* `callback` which is a callback function which is executed when the response from the API is received. Specify 'nil' for returning response.

To get the status, or job result if the job is complete
```ruby
client.get_job_status(jobID, method(:callback))
```

##### Result API
The Result API checks the result of your job request. If it is finished processing, it will return the result. If it not, the call the wait until the result is returned or until it times out. **It is recommended to use the Status API over the Result API to avoid time outs**

```ruby
client.get_job_result(jobID, method(:callback))
```
* `jobID` is the job ID of request returned after performing an asynchronous request
* `callback` which is a callback function which is executed when the response from the API is received. Specify 'nil' for returning response.

To get the result
```ruby
response = client.get_job_result(jobID, nil)
```

## Using a callback function
Most methods allow optional callback functions which are executed when the response of the API is received.

```ruby
def syncCallback(response)
  response = $parser.parse_payload(response)
  if response != nil
    puts response
  else
    errors = $parser.get_last_errors()
    errors.each { |error|
      eCode = error["error"]
      if eCode == ErrorCode::QUEUED
        jobID = error["jobID"]
        client.get_job_status(jobID, method(:syncCallback))
      elsif eCode == ErrorCode::IN_PROGRESS
        jobID = error["jobID"]
        client.get_job_status(jobID, method(:syncCallback))
      else
        puts eCode
        puts error["detail"]
        puts error["reason"]
      end
    }
  end
end

def asyncCallback(response)
  jobID = $parser.parse_jobid(response)
  client.get_job_status(jobID, method(:syncCallback))
end

params = {:text=> 'I love Haven OnDemand!'}
hodApp = "analyzesentiment"
client.post_request(hodApp, params, true, method(:asyncCallback))
```

## POSTing files
POSTing files is just as easy. Simply include the path to the file you're POSTing in the parameters

```ruby
params = {:file=> 'path/to/file.jpg'}
hodApp = "ocrdocument"
response = hodClient.post_request(hodApp, params, false, nil)
puts response
```

## POSTing files with post_request_combination
POSTing files to a combination API is slightly different from POSting files to a standalone API.

```ruby
files = [{"file1_input_name"=>"file1name.xxx"},{"file2_input_name"=>"file2name.xxx"}]
params = {}
params[:file] = files
hodApp = "name_of_combination_api"
response = client.post_request_combination(hodApp, params, false, nil)
```

## License
Licensed under the MIT License.

## Contributing
We encourage you to contribute to this repo! Please send pull requests with modified and updated code.

1. Fork it ( https://github.com/HPE-Haven-OnDemand/havenondemand-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

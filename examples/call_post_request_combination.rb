require_relative "../lib/havenondemand.rb"

$client = HODClient.new("YOUR_API_KEY", "v1")
$parser = HODResponseParser.new()

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
        sleep(2)
        $client.get_job_status(jobID, method(:syncCallback))
      elsif eCode == ErrorCode::IN_PROGRESS
        jobID = error["jobID"]
        sleep(5)
        $client.get_job_status(jobID, method(:syncCallback))
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
  if jobID != nil
    $client.get_job_status(jobID, method(:syncCallback))
  else
    errors = $parser.get_last_errors()
    errors.each { |error|
      eCode = error["error"]
      puts eCode
      puts error["detail"]
      puts error["reason"]
    }
  end
end

# supposed that a combination API takes 2 input files. ! image file for extracting text from image
# and 1 audio file for extracting text from speech.
# And the names of the file input are ocrFile and speechFile.
# And the name of the combination API is "multiplefileinput"

files = [{"ocrFile"=>"review.jpg"},{"speechFile"=>"attendant_test.mp3"}]
# OR
=begin
#file1 = {"ocrFile"=>"review.jpg"}
#file2 = {"speechFile"=>"attendant_test.mp3"}
files = []
files.push(file1)
files.push(file2)
=end
params["file"] = files
$client.post_request_combination('multiplefileinput', params, true, method(:asyncCallback))

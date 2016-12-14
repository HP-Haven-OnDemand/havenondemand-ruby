require 'json'
require 'Unirest'

class HODClient
  def initialize(apikey, version="v1")
    # Instance variables
    if apikey=='http://api.havenondemand.com' || apikey=='http://api.havenondemand.com/' || apikey=='https://api.havenondemand.com' || apikey=='https://api.havenondemand.com/'
      raise ArgumentError, "Using an outdated wrapper constructor method. No need to include API URL.\nInclude as such:\n client = HODClient(API_KEY, VERSION)\n where version is optional"
    end
    @apikey = apikey
    @ver = version
    @hodAppBase = "https://api.havenondemand.com/1/api/";
    @hodJobResultBase = "https://api.havenondemand.com/1/job/result/";
    @hodJobStatusBase = "https://api.havenondemand.com/1/job/status/";
    @hodCombineAsync = "async/executecombination";
	  @hodCombineSync = "sync/executecombination";
    @timeoutVal = 120
  end


  def get_job_status(jobID,callback)
    data={"apikey"=>@apikey}
    response=Unirest.post "#{@hodJobStatusBase}#{jobID}",
                    headers:{ "Accept" => "application/json" },
                    parameters:data
    if response.code == 200
      if callback != nil
        callback.call(response.body)
      else
        return response.body
      end
    else
      puts "Error: #{response.body}"
      err = create_error_object(response.body["error"],response.body["reason"],response.body["detail"],"")
      if callback != nil
        callback.call(err)
      else
        return err
      end
    end
  end

  def get_job_result(jobID,callback)
    data={"apikey"=>@apikey}
    response=Unirest.post "#{@hodJobResultBase}#{jobID}",
                      headers:{ "Accept" => "application/json" },
                      parameters:data
    if response.code == 200
      if callback != nil
        callback.call(response.body)
      else
        return response.body
      end
    else
      err = create_error_object(response.body["error"],response.body["reason"],response.body["detail"],"")
      if callback != nil
        callback.call(err)
      else
        return err
      end
    end
  end

  def get_request(hodApp, params, async=false,callback)
    url=''
    if async == true
        url = "#{@hodAppBase}async/#{hodApp}/#{@ver}?apikey=#{@apikey}"
    else
        url = "#{@hodAppBase}sync/#{hodApp}/#{@ver}?apikey=#{@apikey}"
    end
    params.each do |key, value|
      if "#{key}" == "file"
				raise ArgumentError, "File upload must be used with PostRequest method"
      else
        if value.kind_of?(Array)
          value.each { |x|
            p = "&#{key}=#{x}"
            url = [url, p].join()
          }
        else
          p = "&#{key}=#{value}"
          url = [url, p].join()
        end
			end
    end
    Unirest.timeout(@timeoutVal)

    response=Unirest.get ("#{url}")
    if response.code == 200
      if callback != nil
        callback.call(response.body)
      else
        return response.body
      end
    else
      puts "Error: #{response.body}"
      err = create_error_object(response.body["error"],response.body["reason"],response.body["detail"],"")
      if callback != nil
        callback.call(err)
      else
        return err
      end
    end
  end

  def post_request(hodApp, params, async=true, callback)
    endPoint = ''
    if async == true
      endPoint = "#{@hodAppBase}async/#{hodApp}/#{@ver}"
    else
      endPoint = "#{@hodAppBase}sync/#{hodApp}/#{@ver}"
    end
    data = {}
    data.compare_by_identity
    data["apikey"]=@apikey
    params.each do |key, value|
      if "#{key}" == "file"
        if value.kind_of?(Array)
          value.each { |file|
            data["file"] =  File.new(file, 'rb')
          }
        else
          data["file"] =  File.new(value, 'rb')
        end
      else
        if value.kind_of?(Array)
          value.each { |x|
            data["#{key}"] =  x
          }
        else
          data["#{key}"] =  value
        end
      end
    end
    Unirest.timeout(@timeoutVal)
    response=Unirest.post endPoint,
                        headers:{ "Accept" => "application/json", "Content-Type" => "application/json"},
                        parameters:data

    if response.code == 200
      if callback != nil
        callback.call(response.body)
      else
        return response.body
      end
    else
      puts "Error: #{response.body}"
      err = create_error_object(response.body["error"],response.body["reason"],response.body["detail"],"")
      if callback != nil
        callback.call(err)
      else
        return err
      end
    end
  end

  def get_request_combination(hodApp, params, async=false, callback)
    url=''
    if async == true
        url = "#{@hodAppBase}#{@hodCombineAsync}/#{@ver}"
    else
        url = "#{@hodAppBase}#{@hodCombineSync}/#{@ver}"
    end
    url = [url, "?apikey=#{@apikey}&combination=#{hodApp}"].join()
    params.each do |key, value|
      if "#{key}" == "file"
				raise ArgumentError, "File upload must be used with post_combination method"
      else
        if valid_json?(value)
          raise ArgumentError, "JSON input must be used with post_combination method"
        else
          p = "\"{\"name\":\"#{key}\",\"value\":\"#{value}\"}\""
          url =  [url, "&parameters=",p].join()
        end
			end
    end
    Unirest.timeout(@timeoutVal)

    response=Unirest.get ("#{url}")
    if response.code == 200
      if callback != nil
        callback.call(response.body)
      else
        return response.body
      end
    else
      puts "Error: #{response.body}"
      err = create_error_object(response.body["error"],response.body["reason"],response.body["detail"],"")
      if callback != nil
        callback.call(err)
      else
        return err
      end
    end
  end

  def post_request_combination(combinationName, params, async=false, callback)
    endPoint=''
    if async == true
      endPoint = "#{@hodAppBase}#{@hodCombineAsync}/#{@ver}"
    else
      endPoint = "#{@hodAppBase}#{@hodCombineSync}/#{@ver}"
    end
    data = {}
    data.compare_by_identity
    data["apikey"]=@apikey
    data["combination"] = combinationName

    params.each do |key, value|
      if "#{key}" == "file"
        if value.kind_of?(Array)
          for index in 0 ... value.size
            value[index].each_pair {|kk,vv|
            data["file_parameters"] =  kk
            data["file"] =  File.new(vv, 'rb')
           }
          end
        else
          value.each_pair {|kk,vv|
          data["file_parameters"] =  kk
          data["file"] =  File.new(vv, 'rb')
         }
        end
      else
        if valid_json?(value)
          p = "{\"name\":\"#{key}\",\"value\":#{value}}"
          data["parameters"] =  p
        else
          p = "{\"name\":\"#{key}\",\"value\":\"#{value}\"}"
          data["parameters"] =  p
        end
			end
    end

    Unirest.timeout(@timeoutVal)
    response=Unirest.post endPoint,
                        headers:{ "Accept" => "application/json", "Content-Type" => "application/json"},
                        parameters:data

    if response.code == 200
      if callback != nil
        callback.call(response.body)
      else
        return response.body
      end
    else
      puts "Error: #{response.body}"
      err = create_error_object(response.body["error"],response.body["reason"],response.body["detail"],"")
      if callback != nil
        callback.call(err)
      else
        return err
      end
    end
  end

  private
  # internal utilitiy method
  def valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end
  def create_error_object(error,reason,detail,jobID)
    errorObj = {}
    errorObj["error"] = error
    errorObj["reason"] = reason
    errorObj["detail"] = detail
    errorObj["jobID"] = jobID
    return errorObj
  end
end

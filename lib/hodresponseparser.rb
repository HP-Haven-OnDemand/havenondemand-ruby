require File.join(File.dirname(__FILE__), "/hoderrorcode.rb")

class HODResponseParser
  @errors
  def initialize()
    @errors = []
  end

  def parse_jobid(response)
		@errors = []
    puts response
    if response.has_key? "jobID" and response["jobID"].length > 0
			return response["jobID"]
		else
			if response.has_key? "error" and response.has_key? "reason"
			  detail = ""
				if response.has_key? "detail"
					detail = response["detail"]
				create_error_object(response["error"], response["reason"],detail,"")
        end
			else
				create_error_object(ErrorCode::INVALID_HOD_RESPONSE, "Invalid HOD response","","")
      end
      return nil
    end
  end
#
  def parse_payload(response)
		@errors = []
		if response.has_key? "actions"
			actions = response["actions"]
			status = actions[0]["status"]
			if status == "queued"
				create_error_object(ErrorCode::QUEUED, "Task is queued","", response["jobID"])
				return nil
			elsif status == "in progress"
				create_error_object(ErrorCode::IN_PROGRESS, "Task is in progress","", response["jobID"])
				return nil
			elsif status == "failed"
				errors = actions[0]["errors"]
        if errors.kind_of?(Array)
          errors.each { |error|
            detail = ""
    				if error.has_key? "detail"
    					detail = error["detail"]
            end
    				create_error_object(error["error"], error["reason"],detail,error["jobID"])
          }
        else
          detail = ""
    			if errors.has_key? "detail"
    				detail = errors["detail"]
          end
    			create_error_object(errors["error"], errors["reason"],detail,errors["jobID"])
        end
				return nil
			else
				return actions[0]["result"]
      end
		else
      # must make sure this is an error message. Not just an error key from a good result
			if response.has_key? "error" and response.has_key? "reason"
        detail = ""
				if response.has_key? "detail"
					detail = response["detail"]
				create_error_object(response["error"], response["reason"],detail,"")
				return nil
        end
			else
				return response
      end
    end
  end

  def get_last_errors()
    return @errors
  end
#
  private
  def create_error_object(error,reason,detail,jobID)
    errorObj = {}
    errorObj["error"] = error
    errorObj["reason"] = reason
    errorObj["detail"] = detail
    errorObj["jobID"] = jobID
    @errors.push(errorObj)
  end
end

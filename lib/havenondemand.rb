

require 'unirest'
require 'json'
#require 'httpclient'
#require 'byebug'






class HODError < StandardError

end



class HODResponse

  attr_accessor :response

  def initialize(response)
    #@query=query

    @response=response
  end

  def json()
    @response.body
  end

end

class HODAsyncResponse < HODResponse

  attr_accessor :response
  attr_accessor :jobID
  def initialize(response,client)
    #@query=query
    @response=response
    @client=client
    @jobID =response.body["jobID"]
  end

  def status()
    @client.getStatus(@jobID)
  end

  def result()
    @client.getResult(@jobID)
  end

end



class HODClient
  @@version=1
  @@apidefault="v1"
  def initialize(apikey, version="v1")
    # Instance variables
    if apikey=='http://api.havenondemand.com' || apikey=='http://api.havenondemand.com/' || apikey=='https://api.havenondemand.com' || apikey=='https://api.havenondemand.com/'
      raise ArgumentError, "Using an outdated wrapper constructor method. No need to include API URL.\nInclude as such:\n client = HODClient(API_KEY, VERSION)\n where version is optional"
    end
    @@apidefault=version
    @url = "https://api.havenondemand.com"
    @apikey = apikey

  end


  def getStatus(jobID)
    data={"apikey"=>@apikey}
    response=Unirest.post "#{@url}/#{@@version}/job/status/#{jobID}",
                    headers:{ "Accept" => "application/json" },
                    parameters:data
    return HODResponse.new(response)

  end

  def getResult(jobID)
    data={"apikey"=>@apikey}
    response=Unirest.post "#{@url}/#{@@version}/job/result/#{jobID}",
                      headers:{ "Accept" => "application/json" },
                      parameters:data
    return HODResponse.new(response)
  end

  def deleteIndex(index)
    if index.class.name=="HODIndex"
      index=index.name
    end

    data=Hash.new
    data[:index]=index

    delete=post("deletetextindex",data)
    confirm=delete.json()["confirm"]
    data[:confirm]=confirm
    delete=post("deletetextindex",data)
    return delete
  end

  def deleteConnector(connector)
    data=connectorUtil(connector)
    delete=post("deleteconnector",data)
    return delete
  end


  def connectorUtil(connector)
    if index.class.name=="HODConnector"
      connector=connector.name
    end
    data=Hash.new
    data[:connector]=connector
    return data
  end


  def startConnector(connector)
    data=connectorUtil(connector)
    return post("startconnector",data)
  end

  def retrieveConnectorConfig(connector)
    data=connectorUtil(connector)
    return post("retrieveconfig",data)
  end

  def connectorstatus(connector)
    data=connectorUtil(connector)
    return post("connectorstatus",data)
  end

  def post_combination(combination, data=Hash.new, async=false)
    handler="executecombination"
    data[:apikey]=@apikey
    syncpath="sync"
    syncpath="async" if async
    data[:combination] = combination
    data[:parameters] = data[:parameters].to_json
    Unirest.timeout(30)

    response=Unirest.post "#{@url}/#{@@version}/api/#{syncpath}/#{handler}/#{@@apidefault}",
                        headers:{ "Accept" => "application/json", "Content-Type" => "application/json"},
                        parameters:data
    if response.code == 200

      if async
        return HODAsyncResponse.new(response,self)
      end
      return HODResponse.new(response)
    else
      puts response.body
      #puts data[:json].encoding.name
      raise HODError.new "Error #{response.body["error"]} -- #{response.body["reason"]}"
    end

  end

  def post(handler, data=Hash.new, async=false)
    data[:apikey]=@apikey
    syncpath="sync"
    if async
      syncpath="async"
    end
    Unirest.timeout(30)
    response=Unirest.post "#{@url}/#{@@version}/api/#{syncpath}/#{handler}/#{@@apidefault}",
                        headers:{ "Accept" => "application/json", "Content-Type" => "application/json"},
                        parameters:data
    if response.code == 200

      if async
        return HODAsyncResponse.new(response,self)
      end
      return HODResponse.new(response)
    else
      puts response.body
      #puts data[:json].encoding.name
      raise HODError.new "Error #{response.body["error"]} -- #{response.body["reason"]}"
    end
  end



  def getIndex(name)
    #indexes=self.listIndexes()

    index=HODIndex.new(name,client:self)
    #puts (index in indexes)

  end



  def createIndex(name,flavor="standard",parametric_fields=[],index_fields=[])
    data=Hash.new
    data[:index]=name
    data[:flavor]=flavor
    data[:parametric_fields]=parametric_fields
    data[:index_fields]=index_fields
    self.post("createtextindex",data)
    return HODIndex.new(name,client:self)
  end

  def listIndexes()
    r=post("listindex")

    indexes=r["index"].map { |index| HODIndex.new(index["index"],index["flavor"],index["type"],client:self)}

  end


  def addDoc(doc, index)
      self.addDocs([doc],index)
  end

  def addDocs(docs, index,async=false)


    #  puts docs
    #  puts docs.length
    #jsondocs= docs.map { |doc| doc.data}
    jsondocs=docs
    #puts jsondocs
    docs=Hash.new
    docs[:documents]=jsondocs

    #puts docs.to_json
    docs=docs.to_json
    puts docs.length
    #puts docs
    #docs=render :json => JSON::dump(docs)
    data={json:docs,index:index}

    return self.post("addtotextindex",data,async)
  end

end

class HODConnector

    attr_reader :client
    attr_reader :name


  def initialize(name,client=nil)
    @name=name
    @client=client
  end

  def create(type="web",config=Hash.new, destination="", schedule="",description="")
    config("addtotextindex",type,config,destination,schedule,description)
  end


  def update(type="web",config=Hash.new, destination="", schedule="",description="")
    config("addtotextindex",type,config,destination,schedule,description)
  end

  def config(method,type="",config="", destination="", schedule="",description="")
    data=Hash.new
    data[:connector]=@name
    if type!=""
      data[:type]=type
    end
    if config!=""
      data[:config]=JSON.dump config
    end
    if destination!=""
      destination={"action"=>"addtotextindex", "index" => destination }
      data[:destination]=JSON.dump destination
    end
    if schedule != ""
      data[:schedule]=JSON.dump schedule
    end
    data[:description]=description
    result=@client.post(method,data)
    puts result
  end

  def delete()
    @client.deleteConnector(@name)
  end

  def config()
    @client.retrieveConnectorConfig(@name)
  end

  def status()
    @client.connectorStatus(@name)
  end

  def ==(other_object)
    comparison_object.equal?(self) || (comparison_object.instance_of?(self.class) && @name == other_object.name)
  end
end





class HODIndex

    attr_reader :client
    attr_reader :name


  def initialize(name,flavor="standard",type="normal",client:nil)
    @name=name

    @client=client
    @docs=[]
  end

    def query(text,data=Hash.new)
      data[:database_match]=@name

      data[:text]=text
    result=@client.post("querytextindex",data)
    result["documents"].map!{|doc| HODDoc.new(doc) }
      return result
    end
   def size()
      return @docs.length
    end
  def pushDoc(doc)
    @docs.push(doc)

  end

  def commit(async=false)
#		docs={document:@docs}
#		data={json:docs.to_json,index:@name}
#		puts docs.to_json

    #r=@client.post("addtotextindex",data)
    #@docs=[]
    response=addDocs(@docs,async)
    @docs=[]
    return response
  end

  def addDoc(doc)
    docs=Hash.new

#		docs[:document]=[doc.data]
#		data={json:docs.to_json,index:@name}
#		@client.postasync("addtotextindex",data)
    puts @client.addDoc(doc,@name)
  end


  def addDocs(docs,async=false)

#		docs[:document]=[doc.data]
#		data={json:docs.to_json,index:@name}
#		@client.postasync("addtotextindex",data)

    return @client.addDocs(docs,@name,async)
  end

  def delete()
    clientcheck()
    @client.deleteIndex(self)
  end

  def ==(other_object)
    comparison_object.equal?(self) || (comparison_object.instance_of?(self.class) && @name == other_object.name)
  end
end



class HODDoc

    attr_accessor :data
    attr_accessor :sentiment
    attr_accessor :entities
  def initialize(data)
    #@query=query
    @entities=Hash.new
    @data=data
  end

  def to_json(options={})
      return render :json => JSON::dump(@data)
  end



end

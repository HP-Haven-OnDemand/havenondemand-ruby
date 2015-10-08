Note: this branch is depreciated. All future work will be done on master [here](https://github.com/HP-Haven-OnDemand/havenondemand-node/).

# iodruby

Ruby Gem to help call IDOL OnDemand API.
 [http://idolondemand.com](http://idolondemand.com)


## Installation

To install from rubygems.org.

```
gem install iodruby
```

To install the latest version from this github repo, use the specific_install gem.

```
gem install specific_install
gem specific_install https://github.com/HP-IDOL-OnDemand/iodruby
```


## Usage


### Importing
When using rails and other frameworks with a gem file, include it in it.
```ruby
gem "iodruby"
```
Or, require it directly in your app.
```ruby
require "iodruby"
```

###Initializing the client

```ruby
client = IODClient.new("http://api.idolondemand.com", $apikey)
```

All that is needed to initialize the client is an apikey and the url of the API.


###Sending requests

```ruby
r = client.post('analyzesentiment', {:text=>'I like cats'})
```
The client's *post* method takes the apipath that you're sending your request to as well as an object containing the parameters you want to send to the api. You do not need to send your apikey each time as the client will handle that automatically

###Posting files
```ruby
r = client.post('ocrdocument', {:file=>File.new("/path/to/file", 'rb')})
```
Sending files is just as easy.

```ruby
r = client.post('ocrdocument', {:mode=>'photo',:file=>File.new("/path/to/file", 'rb')})
r = client.post('ocrdocument', {:mode=>'photo',:file=>File.new("/path/to/file", 'rb')})
```
Any extra parameters should be added in the same way as regular calls, or in the data parameter.

###Parsing the output

```ruby
myjson = r.json()
```

The object returned is a response object from the python [requests library](http://docs.python-requests.org/en/latest/) and can easily be turned to json.

```ruby
docs = myjson["documents"]
array.each {|doc| puts doc["title"] }
```

###Indexing

**Creating an index**

```ruby
index = client.createIndex("mytestindex", flavor="explorer")
```

An Index object can easily be created

**Fetching indexes/an index**

```ruby
index = client.getIndex('myindex')
```
The getIndex call will return an iodindex Index object but will not check for existence.

```ruby
indexes = client.listIndexes()
indexes.fetch('myindex', client.createIndex('myindex'))
```

Here we first check the list of our indexes and return a newly created index if the index does not already exist

**Deleting an index**

```ruby
index.delete()
client.deleteIndex('myindex')
```
An index can be deleted in two equivalent ways

**Indexing documents**

```ruby
doc1 = IODDoc.new({title: "title1", reference: "doc1", content: "my content 1"})
doc2 = IODDoc.new({title: "title2", reference: "doc2", content: "my content 2"})
```
Documents can be created as regular python objects

```
index.addDoc(doc1)
index.addDocs([doc1,doc2])
```

They can be added directly one at a time or in a batch.

```
for doc in docs:
  index.pushDoc(doc)
index.commit()
```

An alternative to *addDocs* and easy way to keep batch documents is to use the pushDoc method, the index will keep in memory a list of the documents it needs to index.

```
if index.countDocs()>10:
  index.commit()
```

It makes it easy to batch together groups of documents.

####Indexing - Connectors

```ruby
client = IODClient.new("http://api.idolondemand.com", $apikey)
conn = IODConnector.new("mytestconnector", client)
conn.create(type="web", config = { "url" => "http://www.idolondemand.com" })
conn.delete()
```


### Asynchronous request

For each call the Async parameter can be set to true to send an asynchronous request.

```ruby
r = client.post('analyzesentiment', {:text => 'I like cats'}, async = true)
print r.json()

# will return status of call, queued or finished
puts r.status().json()
# Will wait until result to return
puts r.result().json()
```

Same thing for indexing.

```ruby
r = index.commit(async = true)
```



## Contributing

1. Fork it ( https://github.com/HP-IDOL-OnDemand/iodruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

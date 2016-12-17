library("RCurl")
library("rjson")

# Accept SSL certificates issued by public Certificate Authorities
calculatePre = function(text){
  options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
  
  h = basicTextGatherer()
  hdr = basicHeaderGatherer()
  
  
  req = list(
    
    Inputs = list(
      
      
      "input1" = list(
        "ColumnNames" = list("text"),
        "Values" = list( list(text),  list(text)  )
      )                ),
    GlobalParameters = setNames(fromJSON('{}'), character(0))
  )
  
  body = enc2utf8(toJSON(req))
  api_key = "i0cQUCIsUBdql5sWXwdRtVPCWP23JhGP4lfmz7INIUK0Wctycg8fej+acSpJC19y9du/NlYFrnppm3EKYzO2gg==" # Replace this with the API key for the web service
  authz_hdr = paste('Bearer', api_key, sep=' ')
  
  h$reset()
  curlPerform(url = "https://ussouthcentral.services.azureml.net/workspaces/50a521edc87c4993bebe9c9e147d0c30/services/4ef63f97a4e04f3fa9c0256e98d3e529/execute?api-version=2.0&details=true",
              httpheader=c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
              postfields=body,
              writefunction = h$update,
              headerfunction = hdr$update,
              verbose = TRUE
  )
  
  headers = hdr$value()
  httpStatus = headers["status"]
  if (httpStatus >= 400)
  {
    print(paste("The request failed with status code:", httpStatus, sep=" "))
    
    # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
    print(headers)
  }
  result = h$value()
  print(fromJSON(result))
result1 <- fromJSON(result)
result1 <- result1$Results$output1$value$Values[[1]][1]
return (result1)
}

//Local host alert request for demo purposes
//This demo uses a Patlite Network Monitor device, replace URL with your Patlite device location and sound setup
const url = "http://192.168.50.149/api/control?sound=31&repeat=3&led=23000";
const Request = Functions.makeHttpRequest({
  url: url,
  method: "GET",
});
// Execute the API request (Promise)
const Response = await Request;
if (Response.error) {
  console.log(Response);
  console.error(Response.error);
  throw Error("Request failed");
}
// Use JSON.stringify() to convert from JSON object to JSON string
// Finally, use the helper Functions.encodeString() to encode from string to bytes
return Functions.encodeString(Response);

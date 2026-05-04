extends Node

const BE_URL = "http://127.0.0.1:3000"
var http_client: HTTPRequest

func _ready():
	# Create HTTP client
	http_client = HTTPRequest.new()
	add_child(http_client)
	http_client.request_completed.connect(_on_request_completed)
	
	print("RustClient: Ready to communicate with Rust server")

func send_hello():
	"""Send a simple hello message to Rust"""
	var url = BE_URL + "/hello"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"message": "Hello from Godot!"})
	
	print("Sending to Rust: %s" % body)
	http_client.request(url, headers, HTTPClient.METHOD_POST, body)

func get_agents():
	"""Get agent data from Rust"""
	var url = BE_URL + "/agents"
	print("Fetching agents from Rust...")
	http_client.request(url)

func get_hello():
	"""Get agent data from Rust"""
	var url = BE_URL + "/"
	print("Fetching data from BE..")
	http_client.request(url)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle response from Rust"""
	if response_code != 200:
		print("ERROR: Rust returned status %d" % response_code)
		return
	
	var response_text = body.get_string_from_utf8()
	print("Response from Rust: %s" % response_text)
	
	# Parse JSON
	var json = JSON.new()
	var data = json.parse_string(response_text)
	
	if data:
		print("Parsed data: %s" % data)

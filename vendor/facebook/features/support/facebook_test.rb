mock_graph_api = lambda do |env|
  uri = "#{env["rack.url_scheme"]}://#{env["SERVER_NAME"]}#{env["PATH_INFO"]}"
  [200, { "Content-Type"  => "text/html" },
    [JSON.pretty_generate({data:[1,2,3]})]
  ]
end

Artifice.activate_with(mock_graph_api)

class Hash
  # http://apidock.com/rails/ActiveSupport/CoreExtensions/Hash/Keys/symbolize_keys
  def symbolize_keys
    replace(inject({}) { |h, (k, v)| h[(k.to_sym rescue k) || k] = v; h })
  end
end

class Facebook
  module Test
    APP = YAML.load_file("facebook.yml").symbolize_keys
    NON_USER = {
      signed_request: "zSlZavxXafQ6vXTE4Z9QTwKbfQwIg2O_8OoQ9RDDULY.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTI5NzI1NjQzMywidXNlciI6eyJjb3VudHJ5IjoidXMiLCJsb2NhbGUiOiJlbl9VUyIsImFnZSI6eyJtaW4iOjIxfX19"
    }
    APP_USER = {
      # example signed_request Facebook sends via POST request
      signed_request: "FG1uGHoaGeNH2lxcfJG8AU1MBosRPTf_Wf6R5HQo-2Y.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTQ1MTY4MDAsImlzc3VlZF9hdCI6MTI5NDUxMjQ3Miwib2F1dGhfdG9rZW4iOiIxMjAwMjc3NDU0MzB8Mi5FS1NJd2FOZ21GN1c3aF9pTV9BM2Z3X18uMzYwMC4xMjk0NTE2ODAwLTUxNDQxN3xHV3dUT3FzWnI1S1pSUTBwVWFEMVB3MjhZSDgiLCJ1c2VyIjp7ImxvY2FsZSI6ImVuX1VTIiwiY291bnRyeSI6InVzIn0sInVzZXJfaWQiOiI1MTQ0MTcifQ",
      # another_signed_request: "ez0cE0fg0d5PTvFSvbdPCxl2xkFBrZH3YGj9rgu74io.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTcyNjAwMDAsImlzc3VlZF9hdCI6MTI5NzI1NjIyOCwib2F1dGhfdG9rZW4iOiIxMjAwMjc3NDU0MzB8Mi54VFZIMjV0WWVZazBIb1ZPcmJta1J3X18uMzYwMC4xMjk3MjYwMDAwLTUxNDQxN3w1MkFYNmpaMWs3ZTNnWk5DRGgyRmVGMjBCV00iLCJ1c2VyIjp7ImNvdW50cnkiOiJ1cyIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjUxNDQxNyJ9",
      access_token: "blahblah",
      user_id: "514417" # extracted from signed_request
    }
    MAL_USER = {
      signed_request: "fsdfsdf.sldkjfsi"
    }
  end
end

FB_TEST_APP = Facebook.new(Facebook::Test::APP)

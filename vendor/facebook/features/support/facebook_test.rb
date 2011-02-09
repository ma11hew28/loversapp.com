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
      signed_request: "fsdfsdf.sldkjfsi" # TODO: get sample from FB
    }
    APP_USER = {
      # example signed_request Facebook sends via POST request
      signed_request: "FG1uGHoaGeNH2lxcfJG8AU1MBosRPTf_Wf6R5HQo-2Y.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTQ1MTY4MDAsImlzc3VlZF9hdCI6MTI5NDUxMjQ3Miwib2F1dGhfdG9rZW4iOiIxMjAwMjc3NDU0MzB8Mi5FS1NJd2FOZ21GN1c3aF9pTV9BM2Z3X18uMzYwMC4xMjk0NTE2ODAwLTUxNDQxN3xHV3dUT3FzWnI1S1pSUTBwVWFEMVB3MjhZSDgiLCJ1c2VyIjp7ImxvY2FsZSI6ImVuX1VTIiwiY291bnRyeSI6InVzIn0sInVzZXJfaWQiOiI1MTQ0MTcifQ",
      user_id: "514417" # extracted from signed_request
    }
    MAL_USER = {
      signed_request: "fsdfsdf.sldkjfsi"
    }
  end
end

FB_TEST_APP = Facebook.new(Facebook::Test::APP)

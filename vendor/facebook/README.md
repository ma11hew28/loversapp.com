Facebook
========

This is a simple gem based on the [Run with Friends source code on GitHub][1]. [Run with Friends][2] is a sample, web-based [Facebook canvas application][3]. [Facebook's Sample Canvas Application][4] documentation explains how it works.

Usage:

    require 'facebook'

    facebook = Facebook.new({
      id: "YOUR_APP_ID",
      secret: "YOUR_APP_SECRET",
      canvas_name: "YOUR_CANVAS_PAGE_NAME" # apps.facebook.com/{canvas_name}/
    })

Decode the [signed_request][5] that Facebook POSTs into a Hash.

    request = facebook.decode_signed_request(params[:signed_request])

Generate a cookie with which to remember the user.

    facebook.user_cookie(request["user_id"])

Coming soon... send calls to the [Facebook Graph API][6].

    Facebook.api("/514417")   # public info (no access_token required)
    facebook.api("/insights") # app info (uses the app access token)
    user.api("/me")           # user info (uses the user access token)
    

  1: https://github.com/facebook/runwithfriends
  2: http://apps.facebook.com/runwithfriends/
  3: http://developers.facebook.com/docs/guides/canvas
  4: http://developers.facebook.com/docs/samples/canvas 
  5: http://developers.facebook.com/docs/authentication/signed_request
  6: http://developers.facebook.com/docs/api/
  
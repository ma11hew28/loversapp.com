var Lovers = {};

(function ($) {

  // Document ready...
  $(function () {
    Lovers.facebook = {
      id: $("body[data-app_id]").data("app_id"),
      canvas_page: $("body[data-canvas_page]").data("canvas_page")
      // auth_url: $("*[data-auth_url]").data("auth_url")
    };

    // Set Lovers.user if logged in.
    (function() {
      var user_id_data = $("body[data-user_id]");
      if (user_id_data) {
        Lovers.user = {
          facebook: {
            id: user_id_data.data("user_id"),
            access_token: $("*[data-access_token]").data("access_token")
          }
        }
      }
    })();

    // Buy gift.
    $("#buy-gift").click(function () {
      Lovers.placeOrder();
    });
  });

  $.extend(Lovers, {
    FBInit: function () {
      FB.init({
        appId:  Lovers.facebook.id,
        xfbml:  true, // parse XFBML
        channelUrl: window.location.protocol + "//" + window.location.host + "/fb/canvas/channel.html"
      });
      FB.Canvas.setAutoResize();
      // Ensure we're on apps.facebook.com.
      if (window == top) { top.location = Lovers.facebook.canvas_page; }
    },

      // link=http://developers.facebook.com/docs/reference/dialogs/&
      // picture=http://fbrell.com/f8.jpg&
      // name=Facebook%20Dialogs&
      // caption=Reference%20Documentation&
      // description=Dialogs%20provide%20a%20simple,%20consistent%20interface%20for%20applications%20to%20interact%20with%20users.&
      // message=Facebook%20Dialogs%20are%20so%20easy!
      // FB.api("/2550/feed", "post", {"message": "hey what's up", "access_token": access_token}, function (response) {
      //   console.log(response);
      // });

    placeOrder: function() {
      // Assign an internal ID that points to a database record
      var order_info = {"gift_id": 1, "to_id": 2550}; // send rose to Aaron

      // calling the API ...
      var obj = {
        method: 'pay',
        order_info: order_info,
        purchase_type: 'item'
      };

      FB.ui(obj, this.callback);
    },

    callback: function(data) {
      // console.log(data);
      if (data['order_id']) {

        var url_with_token = "/me/apprequests/?access_token=" + access_token;

        return true;
      } else {
        //handle errors here
        return false;
      }
    }
  });
})(jQuery);

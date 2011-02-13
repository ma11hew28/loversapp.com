var Lovers = {};

(function ($) {

  // Document ready...
  $(function () {
    Lovers.facebook = {
      id: $("body[data-app_id]").data("app_id"),
      canvas_page: $("body[data-canvas_page]").data("canvas_page")
      // auth_url: $("body[data-auth_url]").data("auth_url")
    };

    // Set Lovers.user if logged in.
    (function () {
      var user_data = $("#home");
      if (user_data) {
        Lovers.user = {
          facebook: {
            id: user_data.data("user_id"),
            access_token: user_data.data("access_token")
          }
        }
      }
    })();

    $("#send-love").click(function () {
      Lovers.sendLove();
    });

    $("#send-gift").click(function () {
      if (true) { // gift_id != 0
        Lovers.placeOrder();
      } else { // gift_id == 0 // it's free; no order necessary
        // Lovers.sendGift(gift_id, to_id); // post gift to wall
      }
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
      if (window == top) { top.location = this.facebook.canvas_page; }

      if (this.user) {
        FB.api("/me/friends?access_token=" + this.user.facebook.access_token, function (friends) {
          console.log(friends);
          var friend_selector = $("#friend-selector" )
          friend_selector.autocomplete({
            source: Lovers.sourceFromFriends(friends.data),
            select: function (event, ui) {
              friend_selector.val(ui.item.label);
              Lovers.to_id = ui.item.value;
              return false;
            },
            focus: function (event, ui) {
              friend_selector.val(ui.item.label);
              Lovers.to_id = ui.item.value;
              return false;
            }
            // source: function (request, response) {
            //   var term = request.term;
            //   response({lable: "", value: ""});
            // }
          });
        });
      }
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

    sendLove: function () {
      console.log(Lovers.to_id);
      top.location = "http://www.facebook.com/dialog/feed?api_id=" +
      Lovers.facebook.id + "&to=" + Lovers.to_id + "&redirect_url=" +
      escape(Lovers.facebook.canvas_page) + "&caption=" +
      escape("{*actor*} loves you.") + "&actions=" +
      escape('[{"text":"Love","href":"http://apps.facebook.com/mylovers/"}]');
    },

    placeOrder: function () {
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

    callback: function (data) {
      if (data['order_id']) {
        var url_with_token = "/me/apprequests/?access_token=" + access_token;
        FB.ui({
          method: "stream.publish",
          attachment: {
            name: "Gift name",
            caption: "Happy Valentine's Day!",
            media: [{
              type: "image",
              href: "http://apps.facebook.com/mylovers/",
              src: "http://runwithfriends.appspot.com/images/gifts/gift-img.png"
            }]
          },
          action_links: [{
            text: "Love",
            href: "http://apps.facebook.com/mylovers/"
          }],
          user_message_prompt: "Wish your friend a great Valentine's Day!"
        });
        return true;
      } else {
        //handle errors here
        return false;
      }
    },

    sourceFromFriends: function (friends) {
      var source = [];
      $.each(friends, function (index, friend) {
        source[index] = {label: friend.name, value: friend.id}
      });
      return source;
    }
  });
})(jQuery);

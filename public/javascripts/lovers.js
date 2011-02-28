var Lovers = {};

(function ($) {

  var generateDialogUrl = function (dialog, params) {
    base  = "http://www.facebook.com/dialog/" + dialog + "?";
    tail = [];
    $.each(params, function(key, value) {
      tail.push(key + "=" + encodeURIComponent(value));
    })
    return base + tail.join("&");
  };

  var sourceFromFriends = function (friends) {
    var source = [];
    $.each(friends, function (index, friend) {
      source[index] = {label: friend.name, value: friend.id}
    });
    return source;
  };

  // Document ready...
  $(function () {
    $.extend(Lovers, {
      facebook: {
        id: $("body[data-app_id]").data("app_id"),
        canvas_page: $("body[data-canvas_page]").data("canvas_page")
        // auth_url: $("body[data-auth_url]").data("auth_url")
      },

      sendLove: function () {
        top.location = generateDialogUrl("feed", {
          "app_id": Lovers.facebook.id,
          "redirect_uri": Lovers.facebook.canvas_page,
          "to": Lovers.to_id,
          "actions": '[{"name":"Love","link":"https://apps.facebook.com/mylovers/"}]'
        });
      },

      sendGift: function (gift_id, to_id) {
        var giftSource = $($("label > img").get(gift_id)).attr("src");
        var giftName = $($("label + p").get(gift_id)).text();

        top.location = generateDialogUrl("feed", {
          "app_id": Lovers.facebook.id,
          "redirect_uri": Lovers.facebook.canvas_page,
          "to": Lovers.order_info.to_id,
          "link": "https://apps.facebook.com/mylovers/",
          "picture": this.host + giftSource,
          "name": giftName,
          "caption": "A gift filled with lots of love.",
          "description": "Wishing you a sweet & loving day!",
          "actions": '[{"name":"Love","link":"https://apps.facebook.com/mylovers/"}]'
        });
      },

      placeOrder: function () {
        // Assign an internal ID that points to a database record
        this.order_info = {
          gift_id: $("input[name=gift_id]:checked").val(),
          to_id:   Lovers.to_id
        };

        if (!this.order_info.to_id) {
          alert("Please enter a friend's name.");
          return false;
        }

        if (!this.order_info.gift_id) {
          alert("Please select a gift.");
          return false;
        }

        // Gift_id 0 (Red Heart) is free.
        if (this.order_info.gift_id === "0") {
          this.sendGift("0", this.order_info.to_id);
          return true;
        }

        // Else, call the API ...
        var obj = {
          method: "pay",
          order_info: this.order_info,
          purchase_type: "item"
        };

        FB.ui(obj, function(data) {
          if (data["order_id"]) {
            Lovers.sendGift(Lovers.order_info.gift_id, Lovers.order_info.to_id);
            return true;
          } else {
            // handle errors here
            return false;
          }
        });
      }
    });

    // Set Lovers.user if logged in.
    (function () {
      var user_data = $("#send-love");
      if (user_data) {
        Lovers.user = {
          facebook: {
            id: user_data.data("user_id"),
            access_token: user_data.data("access_token")
          }
        };

        // I couldn't get caption to work below. I don't think they allow a caption w/o a link.
        // // Get first_name for caption in feed posts.
        // FB.api("/me?fields=first_name&access_token=" + Lovers.user.facebook.access_token, function(response) {
        //   Lovers.user.facebook.first_name = response["first_name"];
        // });
      }
    })();

    $("#friend-selector").focus(function () {
      if (!Lovers.started_typing) {
        $(this).val("").removeClass("placeholder");
        Lovers.started_typing = true;
      }
    });

    $("#send-love .uiButtonConfirm").click(function () {
      Lovers.sendLove();
    });

    $("#send-gift .uiButtonConfirm").click(function () {
      Lovers.placeOrder();
    });
  });

  $.extend(Lovers, {
    host: window.location.protocol + "//" + window.location.host,
    FBInit: function () {
      FB.init({
        appId:  Lovers.facebook.id,
        xfbml:  true, // parse XFBML
        channelUrl: this.host + "/fb/canvas/channel.html"
      });
      FB.Canvas.setAutoResize();
      // Ensure we're on apps.facebook.com.
      if (window == top) { top.location = this.facebook.canvas_page; }

      if (this.user) {
        FB.api("/me/friends?access_token=" + this.user.facebook.access_token, function (friends) {
          var friend_selector = $("#friend-selector")
          friend_selector.autocomplete({
            source: sourceFromFriends(friends.data),
            select: function (event, ui) {
              friend_selector.val(ui.item.label);
              Lovers.to_id = ui.item.value;
              $("#them").html(ui.item.label).addClass("mark")
              return false;
            },
            focus: function (event, ui) {
              friend_selector.val(ui.item.label);
              Lovers.to_id = ui.item.value;
              return false;
            }
          });
        });

        $.get('/fb/canvas/leaders', function(leaders) {
          // leaders.top_lovers
          // leaders.most_loving
          // leaders.most_loved
          console.log(leaders);
        });
      }
    }
  });
})(jQuery);

var Lovers = {};

(function ($) {

  // Array.prototype.uniq = function () {
  //   var o = {}, i, l = this.length, r = [];
  //   for (i=0; i<l; ++i) o[this[i]] = this[i];
  //   for (i in o) r.push(o[i]);
  //   return r;
  // };

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

        // $.get('/fb/canvas/leaders', function(leaders) {
        //   // var leaders = {
        //   //   "top_lovers"  : ["514417","10","1396103677","9","6","8","34","7","54","6","353","5","532","4","35354","3","65563","2","767762","1","676674","5","34564","5"],
        //   //   "most_loving" : ["514417","10","1396103677","9","6","8","34","7","54","6","353","5","532","4","35354","3","65563","2","767762","1","676674","5","34564","5"],
        //   //   "most_loved"  : ["514417","10","1396103677","9","6","8","34","7","54","6","353","5","532","4","35354","3","65563","2","767762","1","676674","5","34564","5"]
        //   // };
        // 
        //   // Get all ids_pts from three leader groups
        //   var grp, i, len, ids_pts = [], ids = [];
        //   // var top_lovers, most_loving, most_loved;
        //   for (grp in leaders) {
        //     ids_pts = ids_pts.concat(leaders[grp]);
        //   }
        // 
        //   // Get ids from ids_pts.
        //   len = ids_pts.length;
        //   for (i=0; i<len; i+=2) ids.push(ids_pts[i]);
        // 
        //   // Ensure ids are unique
        //   var o = {}, i, len = ids.length;
        //   for (i=0; i<len; ++i) o[ids[i]] = ids[i];
        //   ids = []; for (i in o) ids.push(o[i]);
        // 
        //   // Get names from ids.
        //   FB.api("?ids=" + ids.join(",") + "&fields=name&access_token=" +
        //       Lovers.user.facebook.access_token, function(response) {
        // 
        //     // Render user links with names for each leader group.
        //     var html = "", usr, uid, name, pts;
        //     var base = "https://www.facebook.com/profile.php?id=";
        // 
        //     for (grp in leaders) {
        //       ids_pts = leaders[grp], html = ""; // reset html
        //       var j = 0; len = ids_pts.length;
        //       for(i=0; i<len && j<10; i+=2) { // print max of 10
        //         uid = ids_pts[i], pts = ids_pts[i+1];
        //         if (uid === "514417" || uid === "1396103677" ||
        //             uid === "100002034432525") continue; // skip me, mom & sara
        // 
        //         // Get user's name by uid.
        //         name = ""; // reset name
        //         for (usr in response) {
        //           var u = response[usr];
        //           if (u["id"] === uid) {
        //             name = u["name"];
        //             break;
        //           }
        //         }
        // 
        //         html += '<li><a href="' + base + uid + '" target="_top">' +
        //             name + "</a> (" + pts + ")</li>"; ++j;
        //       }
        //       $("#"+grp.replace("_", "-")).html(html);
        //     }
        //   });
        // });
      }
    }
  });
})(jQuery);

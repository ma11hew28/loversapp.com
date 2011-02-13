var Lovers = {};

(function ($) {

  var access_token, $ul_req_pending;

  // Document ready...
  $(function () {

    access_token = $("*[data-access_token]").data("access_token");
    auth_url = $("*[data-auth_url]").data("auth_url");

    $ul_req_pending = $("#requests-pending");

    // Add lovers behavior.
    $("#lover-add").click(function () {
      FB.ui({
        method: "apprequests",
        message: "Choose from your friends.",
        data: {rtype: $("#lover-type").val()}
      }, function (response) {
      });
      return false;
    });

    // Accept lovers behavior.
    $("a.request-accept").live("click", function () {
      var req_data = $(this).closest("li").data("req-data");
    });
    // Ignore lovers behavior.

    // Buy gift.
    $("#buy-gift").click(function () {
      console.log(FB.getSession());
      if(false) {// they have stream post permission
        Lovers.placeOrder(); return false;
      } else {
        // request permission
        // window.top.location = auth_url + "&scope=publish_stream";
      }
    });
  });

  $.extend(Lovers, {

    FBInit: function () {

      var url_with_token = "/me/apprequests/?access_token=" + access_token;

      FB.api(url_with_token, function (response) {

        var $li_sample = $ul_req_pending.find("li:hidden");

        if (response.data) {
          $.each(response.data, function (i, req) {
            var $new_li = $li_sample.clone(),
                data = $.parseJSON(req.data);
            $new_li.find("span.request-name").text(req.from.name);
            $new_li.data("req-data", data);
            $ul_req_pending.append($new_li.show());
            //console.log(data);
          });
        }
      });

      // link=http://developers.facebook.com/docs/reference/dialogs/&
      // picture=http://fbrell.com/f8.jpg&
      // name=Facebook%20Dialogs&
      // caption=Reference%20Documentation&
      // description=Dialogs%20provide%20a%20simple,%20consistent%20interface%20for%20applications%20to%20interact%20with%20users.&
      // message=Facebook%20Dialogs%20are%20so%20easy!
      FB.api("/2550/feed", "post", {"message": "hey what's up", "access_token": access_token}, function (response) {
        console.log(response);
      });
    },

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

// /**
//  * @namespace LVRS public namespace for Lovers
//  */
// LVRS = window.LVRS || {};
//
// LVRS.config = {
//   appId: <%= Lovers::Conf.fb_app_id %>
// };
//
// // LVRS.getName = function(uid, callback) {
// //   LVRS.getProperties(uid, ['name'], callback);
// // }
//
// LVRS.getProperties = function(uid, properties, callback) {
//   FB.api('/' + uid + '?fields=' + properties.join(','), callback);
// }
//
// LVRS.renderRequest = function(rid, uid) {
//   var article = $("<article>", {
//     "id": uid
//   });
//   // article.append($("<img>")); // http://graph.facebook.com/35/picture
//   // para.append($("<a></a>"))
//   //   <p><a>Matt Di Pasquale</a></p>
//   //   <div><a>Confirm</a><a>Not Now</a></div>
//   // </article>
//   $('#requests').append(article);
// };
//
// LVRS.userIterator = function(property, func) {
//   if(!this.user.hasOwnProperty(property))
//     return false;
//
//   var length = this.user[property].length, i;
//   var i;
//   for(i = 0; i < length; i++)
//      func(LVRS.user[property][i]);
// };
//
// LVRS.renderRequests = function() {
//   var requests = $("#requests");
//   this.userIterator('reqs', function(obj) {
//     var rid_uid = obj.split("|");
//     LVRS.renderRequest(rid_uid[0], rid_uid[1]);
//   });
// };
//
// LVRS.renderRelationships = function() {
// //   var requests = $("#..");
// //   this.userIterator('relationships', function(obj) {
// // //render relationships here...
// //   });
// // http://graph.facebook.com/35?fields=name
// };
//
// LVRS.bootstrap = function(user) {
//   this.user = user;
//   this.renderRelationships();
//   this.renderRequests();
// };
//
// // $(function() {
// //   FB.Canvas.setAutoResize();
// //   LVRS.bootstrap(<%#= j @relationships %>);
// // });

var Lovers = {};

(function ($) {

  var access_token, $ul_req_pending;

  // Document ready...
  $(function () {

    access_token = $("body").data("access_token");

    $ul_req_pending = $("#requests-pending");

    // Add lovers behavior.
    $("#lover-add").click(function () {
      FB.ui({
        method: "apprequests",
        message: "Choose from your friends.",
        data: {rtype: $("#lover-type").val()}
      }, function (response) {
        //console.log(response);
      });
      return false;
    });

    // Accept lovers behavior.
    $("a.request-accept").live("click", function () {
      var req_data = $(this).closest("li").data("req-data");
      console.log(req_data);
    });
    // Ignore lovers behavior.
  });

  $.extend(Lovers, {

    FBInit: function () {

      FB.api("/me/apprequests/?access_token=" + access_token, function (response) {

        var $li_sample = $ul_req_pending.find("li:hidden");

        if (response.data) {
          $.each(response.data, function (i, req) {
            var $new_li = $li_sample.clone();
            $new_li.find("span.request-name").text(req.from.name);
            $new_li.data("req-data", $.parseJSON(req.data));
            $ul_req_pending.append($new_li.show());
          });
        }
      });
    }
  });
})(jQuery);

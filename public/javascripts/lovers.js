(function ($) {
  $(function () {
    $("#login").click(function () {
      top.location.href = $(this).data("authurl");
      return false;
    });
    $("#lover-add").click(function () {
      var lover_type;
      lover_type = $("#lover-type").val();
      FB.ui({
        method: "apprequests",
        message: "Choose from your friends.",
        data: {lover_type: lover_type}
      }, function (response) {
        console.log(response);
      });
      return false;
    });
  });
})(jQuery);

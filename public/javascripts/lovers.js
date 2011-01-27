(function ($) {
  $(function () {
    $("#login").click(function () {
      top.location.href = $(this).data("authurl");
    });
  });
})(jQuery);

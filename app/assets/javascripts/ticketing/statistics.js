$(function () {
  $(".chooser span").click(function () {
    $(this).addClass("selected").siblings().removeClass("selected");
    $(".stats *").stop(true, false);
    var tableClass = "." + $(this).data("table");
    $(".stats .table:visible").not(tableClass).slideUp(600, function () {
      $(this).siblings(tableClass).slideDown();
    });
  });
});
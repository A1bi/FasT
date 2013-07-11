//= require _seats

$(function () {
  $(".index table td").click(function () {
    window.location = $(this).siblings().first().find("a").attr("href");
  });
  
  $(".seating").each(function () {
    new Seating($(this));
  });
});
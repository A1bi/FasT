$(function () {
  $("tbody.hover td").click(function () {
    window.location = $(this).siblings().first().find("a").attr("href");
  });
  
  $(".seating").each(function () {
    new Seating($(this));
  });
});
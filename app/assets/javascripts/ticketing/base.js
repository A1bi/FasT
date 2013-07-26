$(function () {
  $("tbody.hover tr").click(function () {
    window.location = $(this).data("path");
  });
  
  $(".seating").each(function () {
    new Seating($(this));
  });
});
//= require _seats
//= require ticketing/base

$(function () {
  $("#cancelAction").click(function (event) {
    $(this).hide().siblings("#cancelForm").show();
    event.preventDefault();
  });
});
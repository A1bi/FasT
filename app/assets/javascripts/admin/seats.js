//= require _seats

$(function () {
  var seating = new Seating($(".seating"));
  seating.initDraggables();
  seating.initSelectables();
});

//= require ./_seating

$(window).load(function () {
  var container = $(".seating");
  var klass = container.is(".editor") ? SeatingEditor : Seating;
  var seating = new klass(container);
  if (klass == Seating) {
    seating.initSeats(function (seat) {
      seat.toggleNumber(true);
    }, function () {
      seating.drawLayer("seats");
    });
  }
});

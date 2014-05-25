//= require ./_seating

$(function () {
  $(".chooser span").click(function () {
    $(this).addClass("selected").siblings().removeClass("selected");
    $(".stats *").stop(true, false);
    var tableClass = "." + $(this).data("table");
    $(".stats .table:visible").not(tableClass).slideUp(600, function () {
      $(this).siblings(tableClass).slideDown();
    });
  });
  
  var seatingBoxes = $(".seating");
  if (seatingBoxes.length) {
    $.getJSON(seatingBoxes.first().data("additional-path"), function (data) {
      seatingBoxes.each(function () {
        var $this = $(this);
        var dateSeats = data.seats[$this.data("date")];
        var seating = new Seating($this);
        seating.initSeats(function (seat) {
          var status = dateSeats[seat.id] ? Seat.Status.Available : Seat.Status.Taken;
          seat.setStatus(status);
        });
      });
    });
  }
});
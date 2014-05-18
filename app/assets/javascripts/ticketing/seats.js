//= require ./_seating

$(window).load(function () {
  var seating = new Seating($(".seating"), function () {
    seating.toggleNumbers(true);
    seating.drawLayer("seats");
  });
});

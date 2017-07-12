//= require ./_seating
//= require ./base

function ReservationGroups(container) {
  this.box = container;
  this.dateSelect = this.box.find(".date select");
  this.seats = this.box.data("seats") || {};
  this.date;
  var _this = this;

  this.getSelectedSeats = function () {
    this.seats[this.date] = this.selector.getSelectedSeatIds();
  };

  this.updateDate = function () {
    if (this.date) {
      this.getSelectedSeats();
    }
    this.date = this.dateSelect.val();
    this.selector.setSelectedSeats(this.seats[this.date]);
  };

  this.seatSelectorIsReady = function () {
    this.updateDate();
  }

  var seatingBox = $(".seating");
  if (seatingBox.length) {
    this.selector = new SeatSelector(seatingBox, this);

    this.dateSelect.change(function () {
      _this.updateDate();
    });

    this.box.find("input.save").click(function () {
      _this.getSelectedSeats();
      $.ajax({
        url: _this.box.data("update-path"),
        dataType: "json",
        method: "PUT",
        data: {
          seats: _this.seats
        },
        complete: function () {
          alert('Die Vorreservierungen wurden erfolgreich gespeichert.');
        }
      });
    });
  }
}

$(window).on('load', function () {
  var box = $(".reservation_groups");
  if (box.length) new ReservationGroups(box);
});

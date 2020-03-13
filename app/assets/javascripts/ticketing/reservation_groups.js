//= require ./_seating

function ReservationGroups(container) {
  this.box = container;
  this.eventSelect = this.box.find(".date select[name=event]");
  this.dateSelect = this.box.find(".date select[name=date]");
  this.groupSelect = this.box.find(".groups select");
  this.seats = this.box.data("seats") || {};
  this.date;
  var _this = this;

  this.getSelectedSeats = function () {
    this.seats[this.date] = this.selector.getSelectedSeatIds();
  };

  this.updateEvent = function () {
    location.href = location.pathname + '?event_id=' + this.eventSelect.val();
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
  };

  var seatingBox = $(".seating");
  if (seatingBox.length) {
    this.selector = new SeatSelector(seatingBox, this);

    this.eventSelect.change(function () {
      _this.updateEvent();
    });

    this.dateSelect.change(function () {
      _this.updateDate();
    });

    this.groupSelect.change(function () {
      location.href = _this.box.data("show-path") + _this.groupSelect.val();
    });

    this.box.find("input.save").click(function () {
      _this.getSelectedSeats();
      $.ajax({
        url: _this.box.data("update-path"),
        method: "PUT",
        data: {
          seats: _this.seats
        },
        success: function () {
          alert('Die Vorreservierungen wurden erfolgreich gespeichert.');
        },
        error: function () {
          alert('Beim Speichern ist ein unbekannter Fehler aufgetreten.');
        }
      });
    });
  }
}

$(window).on('load', function () {
  var box = $(".reservation_groups");
  if (box.length) new ReservationGroups(box);
});

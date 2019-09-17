//= require ./_seating
//= require ./base

function TicketTransfer(container) {
  this.socketId;
  this.box = container;
  this.dateSelect = this.box.find("select");
  this.tickets = this.box.data("tickets");
  var _this = this;

  this.date = function () {
    return this.dateSelect.val();
  };

  this.updateDate = function () {
    this.chooser.setDateAndNumberOfSeats(this.date(), this.tickets.length, function () {

    });
  };

  this.enableReservationGroups = function () {
    var groups = [];
    this.box.find(".reservationGroups :checkbox").each(function () {
      var $this = $(this);
      if ($this.is(":checked")) groups.push($this.prop("name"));
    });

    $.post(this.box.find(".reservationGroups").data("enable-url"), {
      groups: groups,
      socketId: this.socketId
    }).always(function (res) {
      _this.chooser.toggleExclusiveSeatsKey(res.seats);
    });
  };

  this.makeRequest = function (action, method, callbacks) {
    $.ajax({
      url: this.box.data(action + "-path"),
      method: method,
      data: {
        ticket_ids: this.tickets,
        date_id: this.date(),
        socketId: this.socketId
      },
      success: callbacks.success,
      error: callbacks.error
    });
  };

  this.seatChooserIsReady = function () {
    this.socketId = this.chooser.socketId;
    this.updateDate();
    this.makeRequest("init", "post", {
      error: function () {
        alert("Leider ist bei der Initialisierung ein Fehler aufgetreten.");
      }
    });
  };

  this.seatChooserIsReconnecting = function () {};

  this.seatChooserDisconnected = function () {
    alert("Die Verbindung zum Server wurde unterbrochen.");
  };

  this.seatChooserCouldNotReconnect = this.seatChooserDisconnected;

  this.seatChooserCouldNotConnect = function () {
    alert("Derzeit ist keine Umbuchung möglich.");
  };

  this.seatChooserExpired = function () {
    alert("Die Sitzung ist abgelaufen.");
  };

  this.returnToOrder = function () {
    window.location = this.box.data("order-path");
  };

  var seatingBox = $(".seating");
  if (seatingBox.length) {
    this.chooser = new SeatChooser(seatingBox, this);

    this.dateSelect.change(function () {
      _this.updateDate();
    });

    this.box.find(".reservationGroups :checkbox").prop("checked", false).click(function () {
      _this.enableReservationGroups();
    });
  }

  var buttons = this.box.find(".submit button");
  buttons.first().click(function () {
    _this.returnToOrder();
  });

  buttons.last().click(function () {
    if (!_this.chooser || _this.chooser.validate()) {
      _this.makeRequest("update", "patch", {
        success: function () {
          _this.returnToOrder();
        },
        error: function () {
          alert("Leider ist bei der Umbuchung ein Fehler aufgetreten.");
        }
      });
    } else {
      $("body").animate({ scrollTop: _this.box.position().top });
    }
  });
}

$(window).on('load', function () {
  var transferBox = $(".transfer");
  if (transferBox.length) new TicketTransfer(transferBox);
});

//= require socket.io-client/dist/socket.io.js

function Seating(container) {
  this.container = container;
  this.eventId = this.container.data('event-id');
  this.allSeats;
  this.seats = {};
  var _this = this;

  this.initPlan = function (callback) {
    this.container.find('.plan').load(this.container.data('plan-path'), function () {

      this.plan = this.container.find('svg');
      this.allSeats = this.plan.find('[fast\\:seat]')
        .each(function (_i, seat) {
          var $seat = $(seat);
          this.seats[parseInt($seat.attr('fast:id'))] = $seat;
        }.bind(this))
        .click(function (event) {
          if (this.clickedSeat) this.clickedSeat($(event.currentTarget));
        }.bind(this))

      if (callback) callback();

    }.bind(this));
  };
};

function SeatingStandalone(container) {
  Seating.call(this, container);
};

function SeatSelector(container, delegate) {
  Seating.call(this, container);
  this.delegate = delegate;
  var _this = this;

  this.selectedSeats = [];

  this.clickedSeat = function (seat) {
    var selected = seat.status === Seat.Status.Exclusive;
    if (selected) {
      this.selectedSeats.splice(this.selectedSeats.indexOf(seat), 1);
    } else {
      this.selectedSeats.push(seat);
    }
    seat.setStatus(selected ? Seat.Status.Default : Seat.Status.Exclusive);
    this.drawSeatsLayer();
  };

  this.setSelectedSeats = function (seats) {
    this.selectedSeats.forEach(function (seat) {
      seat.setStatus(Seat.Status.Default);
    });
    this.selectedSeats = [];

    (seats || []).forEach(function (seatId) {
      var seat = _this.seats[seatId];
      _this.selectedSeats.push(seat);
      seat.setStatus(Seat.Status.Exclusive);
    });
    this.drawSeatsLayer();
  };

  this.getSelectedSeatIds = function () {
    return this.selectedSeats.map(function (seat) {
      return seat.id;
    });
  };

  this.initSeats(function (seat) {
    seat.toggleNumber(true);
    seat.updateStatusShape();
  }, function () {
    if (_this.delegate.seatSelectorIsReady) {
      _this.delegate.seatSelectorIsReady();
    }
  });
}

function SeatChooser(container, delegate) {
  Seating.call(this, container);

  this.date = null;
  this.seatsInfo = {};
  this.numberOfSeats = 0;
  this.node = null;
  this.socketId;
  this.errorBox = this.container.find(".error");
  this.delegate = delegate;
  this.noErrors = false;
  var _this = this;

  this.updateSeats = function (seats) {
    var updatedSeats = {};
    for (var dateId in seats) {
      this.seatsInfo[dateId] = this.seatsInfo[dateId] || {};
      updatedSeats[dateId] = updatedSeats[dateId] || {};
      for (var seatId in seats[dateId]) {
        var seat = updatedSeats[dateId][seatId] = this.seatsInfo[dateId][seatId] = this.seatsInfo[dateId][seatId] || {};
        var seatInfo = seats[dateId][seatId];
        seat.taken = !!seatInfo.t;
        seat.chosen = !!seatInfo.c;
        seat.exclusive = !!seatInfo.e;
      }
    }
    this.updateSeatPlan(updatedSeats);
  };

  this.updateSeatPlan = function (updatedSeats) {
    if (!this.date) return;
    console.log("Updating seating plan");
    updatedSeats = (updatedSeats || this.seatsInfo)[this.date];

    for (var seatId in updatedSeats) {
      var seat = this.seats[seatId];
      if (!seat) continue;
      var seatInfo = updatedSeats[seatId];
      var status;
      var oldStatus = seat.data('status');
      if (seatInfo.chosen) {
        status = 'chosen';
      } else {
        if (seatInfo.taken && !seatInfo.chosen) {
          status = 'taken';
        } else if (seatInfo.exclusive) {
          status = 'exclusive';
        } else if (!seatInfo.taken && !seatInfo.chosen) {
          status = 'available';
        }
      }
      this.setStatusForSeat(seat, status);
    }
  };

  this.setStatusForSeat = function (seat, status) {
    seat.removeClass('status-' + seat.data('status'));
    seat.addClass('status-' + status);
    seat.find('use').attr('xlink:href', '#seat-' + status);
    seat.data('status', status);
  };

  this.chooseSeat = function (seat) {
    var originalStatus = seat.data('status');
    var allowedStatuses = ['available', 'exclusive', 'chosen'];
    if (allowedStatuses.indexOf(originalStatus) == -1) return;

    var newStatus = (originalStatus == 'chosen') ? 'available' : 'chosen';
    this.setStatusForSeat(seat, newStatus);

    this.node.emit('chooseSeat', { seatId: parseInt(seat.attr('fast:id')) }, function (res) {
      if (!res.ok) this.setStatusForSeat(seat, originalStatus);
      this.updateErrorBoxIfVisible();
    }.bind(this));
  };

  this.setDateAndNumberOfSeats = function (date, number, callback) {
    this.numberOfSeats = number;
    if (this.date != date) {
      this.date = date;
      this.updateSeatPlan();
    }
    this.updateErrorBoxIfVisible();

    this.node.emit("setDateAndNumberOfSeats", {
      date: this.date,
      numberOfSeats: this.numberOfSeats
    }, callback);
  };

  this.updateErrorBox = function () {
    var number = this.getSeatsYetToChoose();
    var toggle = number > 0;

    if (toggle) {
      togglePluralText(this.errorBox, number);
    }

    this.toggleErrorBox(toggle);
  };

  this.updateErrorBoxIfVisible = function () {
    if (this.errorBox.is(":visible")) this.updateErrorBox();
  };

  this.toggleErrorBox = function (toggle) {
    if (!toggle && !this.errorBox.is(":visible")) {
      this.errorBox.hide();
      return;
    }
    if (typeof(this.delegate.slideToggle) == 'function') {
      this.delegate.slideToggle(this.errorBox, toggle);
    } else {
      this.errorBox["slide" + ((toggle) ? "Down" : "Up")].call(this.errorBox);
    }
  };

  this.getSeatsYetToChoose = function () {
    return this.numberOfSeats - this.allSeats.filter('.status-chosen').length;
  };

  this.drawKey = function (toggle) {
    // TODO
  };

  this.validate = function () {
    this.updateErrorBox();
    return this.getSeatsYetToChoose() < 1;
  };

  this.clickedSeat = function (seat) {
    if (seat) this.chooseSeat(seat);
  };

  this.registerEvents = function () {
    $(window).on("beforeunload", function () {
      _this.noErrors = true;
    });

    this.node.on("connect", function () {
      _this.socketId = _this.node.id;
      _this.delegate.seatChooserIsReady();
    });

    this.node.on("updateSeats", function (res) {
      console.log("Seat updates received");
      _this.updateSeats(res.seats);
    });

    this.node.on("error", function (error) {
      if (!(error instanceof Object)) {
        _this.delegate.seatChooserCouldNotConnect();
      }
    });

    var eventMappings = [["expired", "Expired"], ["connect_error", "CouldNotConnect"], ["disconnect", "Disconnected"]];
    for (var i = 0, eLength = eventMappings.length; i < eLength; i++) {
      var mapping = eventMappings[i];
      _this.node.on(mapping[0], (function (event) {
        return function () {
          if (!_this.noErrors) _this.delegate['seatChooser' + event]();
        };
      })(mapping[1]));
    }
  };


  this.initPlan(function () {
    this.node = io('/seating', {
      path: '/node',
      reconnection: false,
      query: {
        event_id: this.eventId
      }
    });

    this.registerEvents();
  }.bind(this));
};


Object.create = Object.create || function (p) {
  function F() {}
  F.prototype = p;
  return new F();
};

SeatingStandalone.prototype = Object.create(Seating.prototype);
SeatChooser.prototype = Object.create(Seating.prototype);

$(window).on('load', function () {
  $('.seating').each(function () {
    var $this = $(this), klass;
    if ($this.is('.standalone')) {
      klass = SeatingStandalone;
    }
    if (klass) new klass($this);
  });
});

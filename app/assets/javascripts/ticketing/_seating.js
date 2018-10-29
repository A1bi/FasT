//= require socket.io-client/dist/socket.io.js

function Seating(container) {
  this.container = container;
  this.eventId = this.container.data('event-id');
  this.allSeats;
  this.seats = {};
  var _this = this;

  this.initPlan = function (callback) {
    this.plan = this.container.find('.plan');

    this.plan.find('.canvas').load(this.container.data('plan-path'), function () {
      this.svg = this.container.find('svg');

      this.svg.find('title').remove();

      var content = this.svg.find('> g, > rect, > line, > text');
      var ns = 'http://www.w3.org/2000/svg';
      this.globalGroup = document.createElementNS(ns, 'g');
      this.globalGroup.classList.add('global');
      this.svg[0].appendChild(this.globalGroup);

      for (var i = 0; i < content.length; i++) {
        this.globalGroup.appendChild(content[i]);
      }

      this.globalGroup.addEventListener('transitionend', function (event) {
        if (event.propertyName === 'transform') {
          this.svg.toggleClass('numbers', this.plan.is('.zoomed'));
        }
      }.bind(this));

      this.svg.find('.shield').click(function (event) {
        this.clickedShield(event.currentTarget);
      }.bind(this));

      this.allSeats = this.svg.find('.seat')
        .each(function (_i, seat) {
          var $seat = $(seat);
          var text = '';
          if ($seat.data('row')) {
            text += 'Reihe ' + $seat.data('row') + ' – ';
          }
          text += 'Sitz ' + $seat.data('number');
          var title = document.createElementNS(ns, 'title');
          title.innerHTML = text;
          $seat.find('text').append(title);
          this.seats[$seat.data('id')] = $seat;
        }.bind(this))
        .click(function (event) {
          if (this.clickedSeat) this.clickedSeat($(event.currentTarget));
        }.bind(this));

      this.container.find('.unzoom').click(this.unzoom.bind(this));

      if (callback) callback();

    }.bind(this));
  };

  this.clickedShield = function (shield) {
    if (this.plan.is('.zoomed')) {
      return;
    }

    $(shield).parent('.block').siblings('.block').addClass('disabled');

    var shieldBox = shield.getBoundingClientRect();
    var groupBox = this.globalGroup.getBoundingClientRect();

    var scale = groupBox.height / shieldBox.height;
    if (shieldBox.width * scale > groupBox.width) {
      scale = groupBox.width / shieldBox.width;
    }
    scale *= .95;

    var left = shieldBox.x + shieldBox.width / 2 - groupBox.x;
    left = (left * 2 - groupBox.width / 2) * 2;

    var top = shieldBox.y + shieldBox.height / 2 - groupBox.y;
    top = (top * 2 - groupBox.height / 2) * 2;

    var origin = left + 'px ' + top + 'px';

    this.zoom(scale, origin);
  };

  this.zoom = function (scale, origin) {
    var zoomed = scale !== 1;
    if (!zoomed) {
      this.svg.removeClass('numbers').find('.block').removeClass('disabled');
    }
    this.plan.toggleClass('zoomed', zoomed);
    this.globalGroup.style.transform = 'scale(' + scale + ')';
    this.globalGroup.style['transform-origin'] = origin;
  };

  this.unzoom = function () {
    this.zoom(1, 'center center');
  };
};

function SeatingStandalone(container) {
  Seating.call(this, container);
  this.initPlan();
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
    console.log('Updating seating plan');
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

    this.node.emit('chooseSeat', { seatId: seat.data('id') }, function (res) {
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

//= require socket.io-client/dist/socket.io.js

function Seating(container) {
  this.container = container;
  this.eventId = this.container.data('event-id');
  this.allSeats;
  this.seats = {};
  var _this = this;

  var isIE = navigator.appName == 'Microsoft Internet Explorer'
           || !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv:11/))
           || (typeof $.browser !== 'undefined' && $.browser.msie == 1);

  var match = navigator.userAgent.match(/Edge\/(\d{1,3})\./);

  this.initPlan = function (callback) {
    this.plan = this.container.find('.plan');

    this.container.find('.unsupported-browser').toggle(isIE);

    this.plan.find('.canvas').load(this.container.data('plan-path'), function () {
      this.svg = this.container.find('svg');
      this.svg[0].setAttribute('preserveAspectRatio', 'xMinYMin');

      var content = this.svg.find('> g, > rect, > line, > text');
      var ns = 'http://www.w3.org/2000/svg';
      this.globalGroup = document.createElementNS(ns, 'g');
      if (this.globalGroup.classList) {
        this.globalGroup.classList.add('global');
      // IE workaround
      } else {
        this.globalGroup.className += ' global';
      }
      this.svg[0].appendChild(this.globalGroup);

      for (var i = 0; i < content.length; i++) {
        this.globalGroup.appendChild(content[i]);
      }

      this.globalGroup.addEventListener('transitionend', function (event) {
        if (event.propertyName === 'transform') {
          this.toggleClassesAfterZoom();
        }
      }.bind(this));

      if (this.svg.find('.block').length === 1) {
        this.svg.addClass('numbers');

      } else {
        this.svg.find('.shield').click(function (event) {
          this.clickedShield(event.currentTarget);
        }.bind(this));
      }

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
    var shieldBBox = shield.getBBox();
    var globalBox = this.globalGroup.getBoundingClientRect();
    var globalBBox = this.globalGroup.getBBox();

    var currentNode = shield.querySelector('rect, path');

    var x = parseFloat(currentNode.getAttribute('x')) || 0;
    var y = parseFloat(currentNode.getAttribute('y')) || 0;

    // calculate offset of the element by summing up the offsets of parent nodes
    while (currentNode.tagName != 'svg') {
      var transform = currentNode.getAttribute('transform');
      if (transform) {
        var matrix = currentNode.transform.baseVal.consolidate().matrix;
        x += matrix.e;
        y += matrix.f;
      }

      // calculate minimum X and Y values for path to get the offset
      if (currentNode.tagName == 'path') {
        var path = currentNode.getAttribute('d');
        var matches = path.match(/([\d\.-]+) ([\d\.-]+)/g);
        var xx = [];
        var yy = [];
        matches.forEach(function (match) {
          var coords = match.split(' ');
          xx.push(parseFloat(coords[0]));
          yy.push(parseFloat(coords[1]));
        });
        x += Math.min.apply(null, xx);
        y += Math.min.apply(null, yy);
      }
      currentNode = currentNode.parentNode;
    }

    var heightExtension = 1.5;
    var scale = globalBox.width / shieldBox.width;
    var scaleY = globalBox.height * heightExtension / shieldBox.height;
    if (scale > scaleY) {
      scale = scaleY;
    } else {
      heightExtension = 1.0;
    }

    var viewBox = this.svg[0].viewBox.baseVal;
    var offsetX = viewBox.x + globalBBox.width / 2 - (x + shieldBBox.width / 2) * scale;
    var offsetY = viewBox.y + globalBBox.height * heightExtension / 2 - (y + shieldBBox.height / 2) * scale;

    this.zoom(scale, offsetX, offsetY, shieldBox);
  };

  this.zoom = function (scale, translateX, translateY, shieldBox) {
    var zoom = scale !== 1;
    var height = this.originalHeight;

    if (zoom) {
      this.originalHeight = this.originalHeight || this.svg.height();
      height = Math.max(this.originalHeight, shieldBox.height * scale);
    } else {
      this.svg.removeClass('numbers zoomed-in').find('.block').removeClass('disabled');
    }

    this.plan.toggleClass('zoomed', zoom);
    this.svg.height(height);
    this.globalGroup.style.transform = 'translate(' + translateX + 'px, ' + translateY + 'px) scale(' + scale + ')';

    if (typeof(this.delegate.slideToggle) == 'function') {
      this.delegate.resizeDelegateBox(false);
    }
  };

  this.unzoom = function () {
    this.zoom(1, 0, 0);
  };

  this.toggleClassesAfterZoom = function () {
    this.svg.toggleClass('numbers zoomed-in', this.plan.is('.zoomed'));
  };

  this.setStatusForSeat = function (seat, status) {
    seat.removeClass('status-' + seat.data('status'));
    seat.addClass('status-' + status);
    seat.find('use').attr('xlink:href', '#seat-' + status);
    seat.data('status', status);
  };
};

function SeatingStandalone(container) {
  Seating.call(this, container);

  this.initPlan(function () {
    var path = this.container.data('seats-path');
    if (path) {
      $.getJSON(path, function (response) {
        if (this.container.is('.chosen')) {
          response.seats.forEach(function (id) {
            var seat = this.seats[id];
            if (seat) {
              this.setStatusForSeat(seat, 'chosen');
            }
          }.bind(this));

        } else {
          var statuses = { 0: 'taken', 1: 'available', 2: 'exclusive' };
          response.seats.forEach(function (seatInfo) {
            var seat = this.seats[seatInfo[0]];
            if (seat) {
              this.setStatusForSeat(seat, statuses[seatInfo[1]]);
            }
          }.bind(this));
        }
      }.bind(this));
    }
  }.bind(this));
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

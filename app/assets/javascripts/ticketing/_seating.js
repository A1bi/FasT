//= require socket.io-client/dist/socket.io

function Seating(container, delegate, zoomable) {
  this.container = container;
  this.delegate = delegate;
  this.zoomable = zoomable !== false;
  this.eventId = this.container.data('event-id');
  this.allSeats;
  this.seats = {};
  this.key = this.container.find('.key > div');
  var _this = this;

  var isIE = navigator.appName == 'Microsoft Internet Explorer'
           || !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv:11/))
           || (typeof $.browser !== 'undefined' && $.browser.msie == 1);

  var match = navigator.userAgent.match(/Edge\/(\d{1,3})\./);

  this.initPlan = function (callback) {
    this.plan = this.container.find('.plan');

    this.container.find('.unsupported-browser').toggle(isIE);

    this.plan.find('.canvas').load(this.container.data('plan-path'), function (response, _status, xhr) {
      this.svg = this.container.find('svg');

      if (!response || !this.svg.length) {
        Raven.captureMessage('Failed to load seating SVG', {
          extra: {
            xhr_response: response,
            xhr_status: xhr.status,
            xhr_status_text: xhr.statusText
          }
        });
        return;
      }

      this.svg[0].setAttribute('preserveAspectRatio', 'xMinYMin');

      if (this.zoomable && this.svg.find('.block').length > 1) {
        var content = this.svg.find('> g, > rect, > line, > path, > text');
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

        this.svg.addClass('zoomable');

        this.svg.find('.shield').click(function (event) {
          this.clickedShield(event.currentTarget);
        }.bind(this));

        this.container.find('.unzoom').click(this.unzoom.bind(this));

        this.unzoom();
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

      if (this.key.length) {
        this.key.find('div').each(function (box) {
          var $this = $(this);
          var status = $this.data('status');

          // if the status class is present, this key has already been
          // created before (e.g. after a reinit of the seating)
          // so in this case don't create it again
          if (status && !$this.is('.status-' + status)) {
            $this.addClass('status-' + status);

            if ($this.is('.icon')) {
              var ns = 'http://www.w3.org/2000/svg';
              var icon = document.createElementNS(ns, 'svg');
              var seat = _this.svg.find('#seat-' + status + '> *')[0];
              if (seat) {
                var width = seat.getAttribute('width');
                var height = seat.getAttribute('height');
                icon.setAttribute('viewBox', '0 0 ' + width + ' ' + height);
                icon.appendChild(seat.cloneNode());
                $this.append(icon);
              } else {
                $this.hide();
              }
            }
          }
        });

        this.toggleExclusiveSeatsKey(false);
      }

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
    var scaledHeight = shieldBox.height * scale;
    if (scaledHeight > globalBox.height * heightExtension) {
      scale = globalBox.height * heightExtension / shieldBox.height;
    } else {
      heightExtension = Math.max(1, scaledHeight / globalBox.height);
    }

    var viewBox = this.svg[0].viewBox.baseVal;
    var offsetX = viewBox.x + globalBBox.width / 2 - (x + shieldBBox.width / 2) * scale;
    var offsetY = viewBox.y + globalBBox.height * heightExtension / 2 - (y + shieldBBox.height / 2) * scale;

    this.zoom(scale, offsetX, offsetY, shield);
  };

  this.zoom = function (scale, translateX, translateY, shield) {
    var zoom = scale !== 1;
    var height = this.originalHeight;
    var topBar = this.container.find('.top-bar');
    var blockName = 'Übersicht';

    if (zoom) {
      this.originalHeight = this.originalHeight || this.svg.height();
      height = Math.max(this.originalHeight, shield.getBoundingClientRect().height * scale);
      blockName = shield.querySelector('text').innerHTML;

      this.addBreadcrumb('zoomed to block', {
        name: blockName
      });
    } else {
      this.svg.removeClass('numbers zoomed-in').find('.block').removeClass('disabled');

      if (this.plan.is('.zoomed')) {
        this.addBreadcrumb('returned to overview');
      }
    }

    this.plan.toggleClass('zoomed', zoom);
    this.svg.height(height);
    this.globalGroup.style.transform = 'translate(' + translateX + 'px, ' + translateY + 'px) scale(' + scale + ')';
    topBar.find('.block-name').text(blockName);

    if (this.delegate && typeof(this.delegate.resizeDelegateBox) == 'function') {
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

  this.toggleExclusiveSeatsKey = function (toggle) {
    if (this.key.length < 1) return;

    this.key.find('.status-exclusive').toggle(toggle);
  };

  this.addBreadcrumb = function (message, data, level) {
    Raven.captureBreadcrumb({
      category: 'seating',
      message: message,
      data: data,
      level: level
    });
  };
};

function SeatingStandalone(container, zoomable) {
  Seating.call(this, container, zoomable);

  this.initPlan(function () {
    var path = this.container.data('seats-path');
    if (path) {
      $.getJSON(path, function (response) {
        if (!response) return;

        if (this.container.is('.chosen')) {
          ['taken', 'chosen'].forEach(function (type) {
            if (!response[type]) return;
            response[type].forEach(function (id) {
              var seat = this.seats[id];
              if (seat) {
                this.setStatusForSeat(seat, type);
              }
            }.bind(this));
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

function SeatSelector(container, delegate, zoomable) {
  Seating.call(this, container, delegate, zoomable);

  this.selectedSeats = [];

  this.clickedSeat = function (seat) {
    var selected = seat.data('status') === 'exclusive';
    var seatId = seat.data('id');
    if (selected) {
      this.selectedSeats.splice(this.selectedSeats.indexOf(seatId), 1);
    } else {
      this.selectedSeats.push(seatId);
    }
    this.setStatusForSeat(seat, selected ? 'available' : 'exclusive');
  };

  this.setSelectedSeats = function (seats) {
    this.selectedSeats.forEach(function (seatId) {
      this.setStatusForSeat(this.seats[seatId], 'available');
    }.bind(this));
    this.selectedSeats = [];

    (seats || []).forEach(function (seatId) {
      var seat = this.seats[seatId];
      if (!seat) return;
      this.selectedSeats.push(seatId);
      this.setStatusForSeat(seat, 'exclusive');
    }.bind(this));
  };

  this.getSelectedSeatIds = function () {
    return this.selectedSeats;
  };

  this.initPlan(function () {
    for (var id in this.seats) {
      this.setStatusForSeat(this.seats[id], 'available');
    }

    if (this.delegate && typeof(this.delegate.seatSelectorIsReady) === 'function') {
      this.delegate.seatSelectorIsReady();
    }
  }.bind(this));
}

function SeatChooser(container, delegate, zoomable, privileged) {
  Seating.call(this, container, delegate, zoomable);

  this.date = null;
  this.seatsInfo = {};
  this.numberOfSeats = 0;
  this.node = null;
  this.socketId;
  this.errorBox = this.container.find(".error");
  this.noErrors = false;
  this.privileged = privileged;
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
    var id = seat.data('id');
    var originalStatus = seat.data('status');
    var allowedStatuses = ['available', 'exclusive', 'chosen'];
    if (allowedStatuses.indexOf(originalStatus) == -1) return;

    var newStatus = (originalStatus == 'chosen') ? 'available' : 'chosen';
    this.setStatusForSeat(seat, newStatus);

    this.node.emit('chooseSeat', { seatId: id }, function (res) {
      if (!res.ok) this.setStatusForSeat(seat, originalStatus);
      this.updateErrorBoxIfVisible();

      this.addBreadcrumb('chose seat', {
        id: id,
        previous_status: originalStatus,
        new_status: newStatus,
        success: res.ok ? 'true' : 'false'
      });
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

  this.reset = function () {
    this.node.emit("reset");
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

  this.validate = function () {
    this.updateErrorBox();
    return this.getSeatsYetToChoose() < 1;
  };

  this.clickedSeat = function (seat) {
    if (seat) this.chooseSeat(seat);
  };

  this.disconnect = function () {
    this.node.disconnect();
  };

  this.connectionFailed = function () {
    this.node.io.skipReconnect = true;
  };

  this.registerEvents = function () {
    $(window).on("beforeunload", function () {
      _this.noErrors = true;
    });

    this.node.on("connect", function () {
      if (!_this.socketId) {
        _this.socketId = _this.node.id;

        _this.node.io.opts.query = {
          restore_id: _this.socketId
        };
      }
      _this.delegate.seatChooserIsReady();
    });

    this.node.on("connect_error", function () {
      if (_this.socketId) return;
      _this.connectionFailed();
      _this.delegate.seatChooserCouldNotConnect();
    });

    this.node.on("reconnecting", function () {
      _this.delegate.seatChooserIsReconnecting();
    });

    this.node.on("reconnect_failed", function () {
      _this.connectionFailed();
      _this.delegate.seatChooserDisconnected();
    });

    this.node.on("updateSeats", function (res) {
      console.log("Seat updates received");
      _this.updateSeats(res.seats);
    });

    this.node.on("error", function (error) {
      if (!(error instanceof Object)) {
        _this.connectionFailed();
        if (_this.socketId) {
          _this.delegate.seatChooserCouldNotReconnect();
        } else {
          _this.delegate.seatChooserCouldNotConnect();
        }
      }
    });

    this.node.on("expired", function () {
      _this.delegate.seatChooserExpired();
    });

    var events = ['connect', 'connect_error', 'reconnecting', 'reconnect_failed', 'error'];
    events.forEach(function (name) {
      _this.node.on(name, function () {
        var isError = name.indexOf('error') > -1 || name.indexOf('fail') > -1;
        _this.addBreadcrumb('node connection event', {
          event: name
        }, isError ? 'error' : 'info');
      });
    });
  };


  this.initPlan(function () {
    this.node = io('/seating', {
      path: '/node',
      reconnectionAttempts: this.privileged ? null : 6,
      query: {
        event_id: this.eventId,
        privileged: !!this.privileged
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

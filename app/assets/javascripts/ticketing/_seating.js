//= require socket.io-client/dist/socket.io.min
//= require KineticJS/kinetic.min

function Seat(id, block, pos) {
  this.id = id;
  this.block = block;
  
  this.item = new Kinetic.Rect({
    width: 20,
    height: 20,
    fill: this.block.color,
    stroke: '#a9a9a9',
    strokeWidth: 1,
    cornerRadius: 3,
    shadowColor: 'silver',
    shadowOffset: [1, 1],
    shadowBlur: 2
  });
  
  this.item.position({ x: pos[0], y: pos[1] });
};

function SeatBlock(id, color) {
  this.id = id;
  this.color = color;
  this.seats = [];
  this.group = new Kinetic.Group({
    x: 0,
    y: 0
  });
  
  this.addSeat = function (id, pos) {
    var seat = new Seat(id, this, pos);
    this.seats.push(seat);
    this.group.add(seat.item);
    return seat;
  };
};

function Seating(container) {
  this.maxCells = { x: 185, y: 80 };
  this.sizeFactors = { x: 3.5, y: 3 };
  this.grid = null;
  this.selecting = false;
  this.stage = null;
  this.layers = {};
  this.seats = {};
  var _this = this;
  
  this.calculateGridCells = function (parent) {
    this.grid = [parent.width() / this.maxCells.x, parent.height() / this.maxCells.y];
  };
  
  this.getGridPos = function (pos) {
    return { position_x: Math.round(pos.left / this.grid[0]), position_y: Math.round(pos.top / this.grid[1]) };
  };
  
  this.changedPos = function (event, ui) {
    var id = ui.helper.data("id");
    $.ajax(_this.container.data("update-url").replace(":id", id), {
      method: "PUT",
      data: {
        seat: _this.getGridPos(ui.position)
      }
    });
  };
  
  this.toggleSelecting = function (event, toggle) {
    if (event.which == 91) {
      this.selecting = toggle;
      this.scroller.toggleClass("selecting", toggle);
    }
  };
  
  this.enableViewLayers = function (layer) {
    this.scroller.addClass(layer);
  };
  
  /*
  this.container.viewChooser.find("a")
    .click(function (event) {
      var $this = $(this);
      if ($this.is(".selected")) return;
  
      $this.addClass("selected").siblings().removeClass("selected");
      _this.scroller.removeClass("numbers underlay photo");
      var viewType = $this.data("type");
      if (viewType == "numbersAndUnderlay") {
        _this.enableViewLayers("numbers underlay");
      } else if (viewType == "photo") {
        _this.enableViewLayers("photo");
      }
  
      event.preventDefault();
    })
    .first().addClass("selected");
  */
  
  this.stage = new Kinetic.Stage({
    container: container.get(0),
    width: container.width(),
    height: container.height()
  });
  
  this.layers['seats'] = new Kinetic.Layer();
  this.stage.add(this.layers['seats']);
  
  var block = new SeatBlock(1, "red");
  this.layers['seats'].add(block.group);
  
  var seat = block.addSeat(1, [100, 60]);
  
  this.layers['seats'].draw();
};

function SeatChooser(container, delegate) {
  Seating.call(this, container);
  
  this.date = null;
  this.allSeats = {};
  this.numberOfSeats = 0;
  this.node = null;
  this.seatingId;
  this.errorBox = this.container.find(".error");
  this.delegate = delegate;
  this.noErrors = false;
	var _this = this;
  
  this.updateSeats = function (seats) {
    for (var dateId in seats) {
      this.allSeats[dateId] = this.allSeats[dateId] || {};
      for (var seatId in seats[dateId]) {
        var seat = this.allSeats[dateId][seatId] = this.allSeats[dateId][seatId] || {};
        var seatInfo = seats[dateId][seatId];
        seat.taken = seatInfo.t;
        seat.chosen = seatInfo.c;
        seat.exclusive = seatInfo.e;
      }
    }
    this.updateSeatPlan();
  };
  
  this.updateSeatPlan = function () {
    if (!this.date) return;
    _this.seats.each(function () {
      var $seat = $(this);
      var seat = _this.allSeats[_this.date][$seat.data("id")];
      $seat.toggleClass("chosen", !!seat.chosen)
        .toggleClass("taken", !!seat.taken && !seat.chosen)
        .toggleClass("available", !seat.taken && !seat.chosen)
        .toggleClass("exclusive", !!seat.exclusive);
    });
  };
  
  this.chooseSeat = function ($seat) {
    if (!$seat.is(".available")) return;
    
    $seat.addClass("chosen");
    
    this.node.emit("chooseSeat", { seatId: $seat.data("id") }, function (res) {
      if (!res.ok) $seat.removeClass("chosen");
      _this.updateErrorBoxIfVisible();
    });
  };
  
  this.setDateAndNumberOfSeats = function (date, number, callback) {
    this.numberOfSeats = number;
    if (this.date != date) {
      this.date = date;
      this.updateSeatPlan();
      this.errorBox.hide();
    } else {
      this.updateErrorBoxIfVisible();
    }
    
    this.node.emit("setDateAndNumberOfSeats", {
      date: this.date,
      numberOfSeats: this.numberOfSeats
    }, callback);
  };
  
  this.updateErrorBox = function () {
    var number = this.getSeatsYetToChoose();
    var toggle = number > 0;
    
    if (toggle) {
      togglePluralText(this.errorBox, number, "error");
    }
    
    if (typeof(this.delegate.slideToggle) == 'function') {
      this.delegate.slideToggle(this.errorBox, toggle);
    } else {
      this.errorBox["slide" + ((toggle) ? "Down" : "Up")].call(this.errorBox);
    }
  };
  
  this.updateErrorBoxIfVisible = function () {
    if (this.errorBox.is(":visible")) this.updateErrorBox();
  };
  
  this.getSeatsYetToChoose = function () {
    return this.numberOfSeats - this.seats.filter(".chosen").length;
  };
  
  this.validate = function () {
    this.updateErrorBox();
    return this.getSeatsYetToChoose() < 1;
  };
  
	this.registerEvents = function () {
    this.seats.click(function () {
      _this.chooseSeat($(this));
		});
    
    $(window).on("beforeunload", function () {
      _this.noErrors = true;
    });
    
    this.node.on("gotSeatingId", function (data) {
      _this.seatingId = data.id;
      _this.delegate.seatChooserGotSeatingId();
      _this.delegate.seatChooserIsReady();
    });
    
    this.node.on("updateSeats", function (res) {
      _this.updateSeats(res.seats);
    });
    
    this.node.on("error", function (error) {
      if (!(error instanceof Object)) {
        _this.delegate.seatChooserCouldNotConnect();
      }
    });
    
    var eventMappings = [["expired", "Expired"], ["connect_failed", "CouldNotConnect"], ["disconnect", "Disconnected"]];
    $.each(eventMappings, function (i, mapping) {
      _this.node.on(mapping[0], function () {
        if (!_this.noErrors) _this.delegate['seatChooser' + mapping[1]]();
      });
    });
	};
  
  this.init = function () {
    this.node = io.connect("/seating", {
      "resource": "node",
      "reconnect": false
    });
    
    this.registerEvents();
  };
  
  $(function () { _this.init(); });
};


Object.create = Object.create || function (p) {
  function F() {}
  F.prototype = p;
  return new F();
};

SeatChooser.prototype = Object.create(Seating.prototype);
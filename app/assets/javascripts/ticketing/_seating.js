//= require socket.io-client/dist/socket.io.min
//= require KineticJS/kinetic.min

function Seat(id, block, number, pos, delegate) {
  this.id = id;
  this.block = block;
  this.delegate = delegate;
  this.selected = false;
  this.draggable = false;
  var _this = this;
  var size = [20, 20];
  var cacheOffset = [5, 5];
  
  this.cache = function () {
    this.item.cache({
      x: -cacheOffset[0],
      y: -cacheOffset[1],
      width: size[0] + cacheOffset[0] * 2,
      height: size[1] + cacheOffset[1] * 2
    });
  };
  
  this.updateBorder = function () {
    this.item.setAttrs({
      stroke: this.selected ? "black" : "white",
      strokeWidth: this.selected ? 1 : 2,
      dash: this.selected ? [5, 5] : [0]
    });
    this.cache();
  };
  
  this.setSelected = function (sel) {
    this.selected = sel;
    this.updateBorder();
  };
  
  this.item = new Kinetic.Rect({
    width: size[0],
    height: size[1],
    fill: this.block.color,
    cornerRadius: 3,
    shadowColor: 'silver',
    shadowOffset: [1, 1],
    shadowBlur: 6,
    name: "seat",
    seat: this
  })
  .position({ x: pos[0], y: pos[1] })
  this.updateBorder();
  
  this.item.on("mousedown", function () {
    _this.delegate.clickedSeat(_this);
  }).on("mouseover", function () {
    _this.delegate.setCursor(_this.draggable && _this.selected ? "move" : "pointer");
  }).on("mouseout", function () {
    _this.delegate.setCursor();
  });
};

function SeatBlock(id, color, delegate) {
  this.id = id;
  this.color = color;
  this.delegate = delegate;
  this.seats = [];
  this.group = new Kinetic.Group({
    x: 0,
    y: 0
  });
  
  this.addSeat = function (id, number, pos) {
    var seat = new Seat(id, this, number, pos, this.delegate);
    this.seats.push(seat);
    this.group.add(seat.item);
    return seat;
  };
};

function Seating(container) {
  this.container = container;
  this.maxCells = { x: 110, y: 80 };
  this.grid = [this.container.width() / this.maxCells.x, this.container.height() / this.maxCells.y];
  this.stage = null;
  this.layers = {};
  this.seats = {};
  this.selecting = false;
  this.selectedSeats = [];
  this.selectedSeatsGroup = [];
  var _this = this;
  
  this.getGridPos = function (pos) {
    return { position_x: Math.round(pos.left / this.grid[0]), position_y: Math.round(pos.top / this.grid[1]) };
  };
  
  this.saveSeatsInfo = function () {
    $.ajax(_this.container.data("update-path"), {
      method: "PUT",
      data: {
        seat: _this.getGridPos(ui.position)
      }
    });
  };
  
  this.toggleSelecting = function (event, toggle) {
    _this.selecting = event.metaKey;
  };
  
  this.enableViewLayers = function (layer) {
    this.scroller.addClass(layer);
  };
  
  this.initSeats = function () {
    $.getJSON("/api/seats", function (data) {
      
      $.each(data.blocks, function (i, blockInfo) {
        var block = new SeatBlock(blockInfo.id, blockInfo.color, _this);
        _this.layers['seats'].add(block.group);
        
        $.each(blockInfo.seats, function (j, seat) {
          var pos = [seat.position[0] * _this.grid[0], seat.position[1] * _this.grid[1]];
          _this.seats[seat.id] = block.addSeat(seat.id, seat.number, pos);
          _this.seats[seat.id].draggable = true;
        });
        
      });
      _this.layers['seats'].draw();
      
    });
  };
  
  this.updateSelectedSeats = function () {
    this.selectedSeatsGroup.moveToTop();
    var delta = this.selectedSeatsGroup.position();
    this.selectedSeatsGroup.setPosition({ x: 0, y: 0 }).find(".seat").each(function(seat) {
      var pos = seat.position();
      seat.position({ x: pos.x + delta.x, y: pos.y + delta.y });
      if (_this.selectedSeats.indexOf(seat.attrs.seat) == -1) {
        seat.moveTo(seat.attrs.seat.block.group);
      }
    });
    
    $.each(this.selectedSeats, function (i, seat) {
      seat.item.moveTo(_this.selectedSeatsGroup);
    });
    
    _this.layers['seats'].draw();
  };
  
  this.clickedSeat = function (seat) {
    if (this.selectedSeats.indexOf(seat) != -1) return;
    seat.setSelected(true);
    if (!this.selecting) {
      $.each(this.selectedSeats, function (i, s) {
        s.setSelected(false);
      });
      this.selectedSeats.length = 0;
    }
    this.selectedSeats.push(seat);
    this.updateSelectedSeats();
  };
  
  this.setCursor = function (type) {
    this.container.css({ cursor: type || "auto" });
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
  
  var planBox = container.find(".plan");
  this.stage = new Kinetic.Stage({
    container: planBox.get(0),
    width: planBox.width(),
    height: planBox.height()
  });
  
  this.layers['seats'] = new Kinetic.Layer();
  this.stage.add(this.layers['seats']);
  
  this.selectedSeatsGroup = new Kinetic.Group({ draggable: true })
  .on("dragend", function () {
    
  });
  this.layers['seats'].add(this.selectedSeatsGroup);
  
  this.initSeats();
  
  $(document).on("keydown keyup", this.toggleSelecting);
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
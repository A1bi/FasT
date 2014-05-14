//= require socket.io-client/dist/socket.io.min
//= require KineticJS/kinetic.min

function Seat(id, block, number, pos, delegate) {
  this.id = id;
  this.block = block;
  this.delegate = delegate;
  this.selected = false;
  this.draggable = false;
  this.status;
  var _this = this;
  var size = [20, 20];
  var cacheOffset = [5, 5];
  
  this.cache = function () {
    this.group.cache({
      x: -cacheOffset[0],
      y: -cacheOffset[1],
      width: size[0] + cacheOffset[0] * 2,
      height: size[1] + cacheOffset[1] * 2
    });
  };
  
  this.setStyle = function (options) {
    var defaultOptions = {
      fill: this.block.color,
      cornerRadius: 3,
      shadowColor: 'silver',
      shadowOffset: [1, 1],
      shadowBlur: 6
    };
    this.item.setAttrs($.extend(defaultOptions, options));
  };
  
  this.updateBorder = function () {
    this.setStyle({
      stroke: this.selected ? "black" : "white",
      strokeWidth: this.selected ? 1 : 2,
      dash: this.selected ? [5, 5] : [0]
    });
  };
  
  this.setSelected = function (sel) {
    this.selected = sel;
    this.updateBorder();
    this.updateStatus();
    this.cache();
  };
  
  this.updateStatus = function () {
    var options, textColor = "white";
    switch (this.status) {
    case Seat.Status.Available:
      options = {
        fill: "green"
      };
      break;
    case Seat.Status.Chosen:
      options = {
        fill: "yellow",
        stroke: "red"
      };
      textColor = "red";
      break;
    case Seat.Status.Taken:
      options = {
        fill: "gray",
        shadowEnabled: false,
        opacity: 0.3
      };
      break;
    case Seat.Status.Exclusive:
      options = {
        fill: "orange",
        stroke: "silver"
      };
      break;
    }
    this.setStyle(options);
    this.text.fill(textColor);
    this.cache();
  };
  
  this.setStatus = function (status) {
    this.status = status;
    this.updateStatus();
  };
  
  this.setDraggable = function (draggable) {
    this.draggable = draggable;
    this.cache();
  };
  
  this.toggleNumber = function (toggle) {
    if (!toggle && this.text) {
      this.text.hide();
    } else if (toggle) {
      if (!this.text) {
        var fontSize = size[1] * 0.6;
        this.text = new Kinetic.Text({
          y: (size[1] - fontSize) / 2,
          width: size[0],
          fontSize: fontSize,
          fontFamily: "Arial",
          fill: "white",
          align: "center",
          text: number
        });
        this.group.add(this.text);
      } else {
        this.text.show();
      }
    }
  };
  
  
  this.group = new Kinetic.Group({
    x: pos[0],
    y: pos[1],
    width: size[0],
    height: size[1],
    name: "seat",
    seat: this
  });
  
  this.item = new Kinetic.Rect();
  this.setStyle({
    width: size[0],
    height: size[1]
  });
  this.group.add(this.item);
  
  this.updateBorder();
  
  this.group.on("mousedown", function () {
    _this.delegate.clickedSeat(_this);
  }).on("mouseover", function () {
    _this.delegate.setCursor(_this.draggable && _this.selected ? "move" : "pointer");
  }).on("mouseout", function () {
    _this.delegate.setCursor();
  });
};
Seat.Status = {
  Available: 0,
  Chosen: 1,
  Taken: 2,
  Exclusive: 3
};

function SeatBlock(id, color, delegate) {
  this.id = id;
  this.color = color;
  this.delegate = delegate;
  this.seats = [];
  this.group = new Kinetic.Group();
  
  this.addSeat = function (id, number, pos) {
    var seat = new Seat(id, this, number, pos, this.delegate);
    this.seats.push(seat);
    this.group.add(seat.group);
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
  this.draggable = this.container.is(".draggable");
  this.selectable = this.draggable || this.container.is(".selectable");
  var _this = this;
  
  this.getGridPos = function (pos) {
    return { position_x: Math.round(pos.x / this.grid[0]), position_y: Math.round(pos.y / this.grid[1]) };
  };
  
  this.saveSeatsInfo = function () {
    var seats = {};
    $.each(this.selectedSeats, function (i, seat) {
      var pos = _this.getGridPos(seat.group.position());
      seats[seat.id] = pos;
    });
    $.ajax(_this.container.data("update-path"), {
      method: "PUT",
      data: { seats: seats }
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
        
        $.each(blockInfo.seats, function (j, seatInfo) {
          var pos = [seatInfo.position[0] * _this.grid[0], seatInfo.position[1] * _this.grid[1]];
          var seat = block.addSeat(seatInfo.id, seatInfo.number, pos);
          seat.toggleNumber(true);
          seat.setDraggable(_this.draggable);
          _this.seats[seatInfo.id] = seat;
        });
        
      });
      _this.drawLayer("seats");
      
    });
  };
  
  this.relocateSelectedSeats = function () {
    var delta = this.selectedSeatsGroup.position();
    this.selectedSeatsGroup.setPosition({ x: 0, y: 0 }).find(".seat").each(function(seat) {
      var pos = seat.position();
      seat.position({ x: pos.x + delta.x, y: pos.y + delta.y });
    });
  };
  
  this.updateSelectedSeats = function () {
    this.relocateSelectedSeats();
    this.selectedSeatsGroup.moveToTop();
    this.selectedSeatsGroup.find(".seat").each(function(seat) {
      if (_this.selectedSeats.indexOf(seat.attrs.seat) == -1) {
        seat.moveTo(seat.attrs.seat.block.group);
      }
    });
    
    $.each(this.selectedSeats, function (i, seat) {
      seat.group.moveTo(_this.selectedSeatsGroup);
    });
    
    _this.drawLayer("seats");
  };
  
  this.clickedSeat = function (seat) {
    if (!this.selectable || this.selectedSeats.indexOf(seat) != -1) return;
    if (!this.selecting) {
      $.each(this.selectedSeats, function (i, s) {
        s.setSelected(false);
      });
      this.selectedSeats.length = 0;
    }
    if (seat) {
      seat.setSelected(true);
      this.selectedSeats.push(seat);
    }
    this.updateSelectedSeats();
  };
  
  this.setCursor = function (type) {
    this.container.css({ cursor: type || "auto" });
  };
  
  this.addLayer = function (name, options) {
    var layer = new Kinetic.Layer(options);
    this.layers[name] = layer;
    this.stage.add(layer);
    return layer;
  };
  
  this.addToLayer = function (layerName, item) {
    this.layers[layerName].add(item);
    return item;
  };
  
  this.drawLayer = function (name) {
    this.layers[name].draw();
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
  
  this.addLayer("seats");
  
  this.addToLayer("seats", new Kinetic.Rect({
    width: this.stage.width(),
    height: this.stage.height()
  }))
  .on("click", function () {
    _this.clickedSeat();
  });
  
  this.selectedSeatsGroup = this.addToLayer("seats", new Kinetic.Group({
    draggable: this.draggable,
    dragBoundFunc: function (pos) {
      return {
        x: Math.floor(pos.x / _this.grid[0]) * _this.grid[0],
        y: Math.floor(pos.y / _this.grid[1]) * _this.grid[1]
      }
    }
  }))
  .on("dragend", function () {
    _this.relocateSelectedSeats();
    _this.saveSeatsInfo();
  });
  
  this.initSeats();
  
  if (this.container.is(".stage")) {
    var stageRectWidth = this.stage.width() * 0.8, stageRectHeight = 40;
    this.addLayer("stage", {
      width: stageRectWidth,
      height: stageRectHeight,
      x: (this.stage.width() - stageRectWidth) / 2,
      y: this.stage.height() - stageRectHeight - 20,
    });
    this.addToLayer("stage", new Kinetic.Rect({
      width: stageRectWidth,
      height: stageRectHeight,
      fill: "#43a1ca",
      cornerRadius: 7
    }));
    var fontSize = stageRectHeight * 0.6;
    this.addToLayer("stage", new Kinetic.Text({
      x: stageRectWidth / 2,
      y: (stageRectHeight - fontSize) / 2,
      text: "Bühne",
      fontSize: fontSize,
      fontFamily: "Qlassik",
      fill: "white"
    }));
    this.drawLayer("stage");
  }
  
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
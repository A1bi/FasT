//= require socket.io-client/dist/socket.io.min
//= require KineticJS/kinetic.min

function Seat(id, block, number, pos, delegate) {
  this.id = id;
  this.block = block;
  this.delegate = delegate;
  this.selected = false;
  this.status;
  var _this = this;
  var size = [20, 20];
  var cacheOffset = [1, 1];
  var cacheSize = [size[0] + cacheOffset[0] * 2, size[1] + cacheOffset[1] * 2];
  
  this.cache = function () {
    this.item.cache({
      x: -cacheOffset[0],
      y: -cacheOffset[1],
      width: cacheSize[0],
      height: cacheSize[1]
    }).position({
      x: -cacheOffset[0],
      y: -cacheOffset[1]
    });
  };
  
  this.setStyle = function (options) {
    var defaultOptions = {
      fill: this.block.color,
      strokeEnabled: false,
      stroke: "white",
      dash: [0],
      cornerRadius: 2,
      opacity: 1
    };
    this.item.setAttrs($.extend(defaultOptions, options));
  };
  
  this.setSelected = function (sel) {
    this.selected = sel;
    this.setStatus(sel ? Seat.Status.Selected : null);
  };
  
  this.updateStatus = function () {
    var options = {}, textColor = "white";
    switch (this.status) {
    case Seat.Status.Available:
      options = {
        fill: "green"
      };
      break;
    case Seat.Status.PreChosen:
    case Seat.Status.Chosen:
      options = {
        fill: "yellow",
        strokeEnabled: true,
        stroke: "red"
      };
      textColor = "red";
      break;
    case Seat.Status.Taken:
      options = {
        fill: "#cacaca"
      };
      break;
    case Seat.Status.Exclusive:
      options = {
        fill: "orange",
        stroke: "silver"
      };
      break;
    case Seat.Status.Selected:
      options = {
        strokeEnabled: true,
        stroke: "black",
        strokeWidth: 1,
        dash: [5, 5]
      };
      break;
    }
    this.setStyle(options);
    if (this.text) this.text.fill(textColor);
    this.cache();
  };
  
  this.setStatus = function (status) {
    if (this.status == status) return;
    this.status = status;
    this.updateStatus();
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
  
  this.group.on("mousedown", function () {
    _this.delegate.clickedSeat(_this);
  }).on("mouseover", function () {
    _this.delegate.mouseOverSeat(_this);
  }).on("mouseout", function () {
    _this.delegate.setCursor();
  });
};
Seat.Status = {
  Available: 0,
  Chosen: 1,
  PreChosen: 2,
  Taken: 3,
  Exclusive: 4,
  Selected: 5
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
  var _this = this;
  
  this.getGridPos = function (pos) {
    return { position_x: Math.round(pos.x / this.grid[0]), position_y: Math.round(pos.y / this.grid[1]) };
  };
  
  this.initSeats = function (seatCallback, afterCallback) {
    $.getJSON("/api/seats", function (data) {
      
      $.each(data.blocks, function (i, blockInfo) {
        var block = new SeatBlock(blockInfo.id, blockInfo.color, _this);
        _this.layers['seats'].add(block.group);
        
        $.each(blockInfo.seats, function (j, seatInfo) {
          var pos = [seatInfo.position[0] * _this.grid[0], seatInfo.position[1] * _this.grid[1]];
          var seat = block.addSeat(seatInfo.id, seatInfo.number, pos);
          _this.seats[seatInfo.id] = seat;
          if (seatCallback) seatCallback(seat);
        });
        
      });
      if (afterCallback) afterCallback();
      
    });
  };
  
  this.toggleNumbers = function (toggle) {
    for (var seatId in this.seats) {
      this.seats[seatId].toggleNumber(toggle);
    }
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
    console.log("Drawing " + name + " layer");
    this.layers[name].draw();
  };
  
  
  this.container.find(".viewChooser a")
  .click(function (event) {
    var $this = $(this);
    if ($this.is(".selected")) return;

    $this.addClass("selected").siblings().removeClass("selected");
    var viewType = $this.data("type"), numbersAndUnderlay = viewType == "numbersAndUnderlay";
    _this.toggleNumbers(numbersAndUnderlay);
    _this.drawLayer("seats");

    event.preventDefault();
  })
  .first().addClass("selected");
  
  var planBox = container.find(".plan");
  this.stage = new Kinetic.Stage({
    container: planBox.get(0),
    width: planBox.width(),
    height: planBox.height()
  });
  
  this.addLayer("seats");
  
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
};

function SeatingEditor(container) {
  Seating.call(this, container);
  
  this.selecting = false;
  this.selectedSeats = [];
  this.selectedSeatsGroup = [];
  var _this = this;
  
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
  
  this.mouseOverSeat = function (seat) {
    this.setCursor(seat.selected ? "move" : "pointer");
  };
  
  this.clickedSeat = function (seat) {
    if (this.selectedSeats.indexOf(seat) != -1) return;
    if (!this.selecting) {
      $.each(this.selectedSeats, function (i, s) {
        s.setSelected(false);
      });
      this.selectedSeats.length = 0;
    }
    if (seat) {
      seat.setSelected(true);
      this.selectedSeats.push(seat);
      this.setCursor("move");
    }
    this.updateSelectedSeats();
  };
  
  
  this.initSeats(function (seat) {
    seat.toggleNumber(true);
  }, function () {
    _this.drawLayer("seats");
  });
  
  this.addToLayer("seats", new Kinetic.Rect({
    width: this.stage.width(),
    height: this.stage.height()
  }))
  .on("click", function () {
    _this.clickedSeat();
  });
  
  this.selectedSeatsGroup = this.addToLayer("seats", new Kinetic.Group({
    draggable: true,
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
  
  $(document).on("keydown keyup", this.toggleSelecting);
};

function SeatChooser(container, delegate) {
  Seating.call(this, container);
  
  this.date = null;
  this.seatsInfo = {};
  this.numberOfSeats = 0;
  this.numberOfChosenSeats = 0;
  this.node = null;
  this.seatingId;
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
    console.log("Updating seating plan");
    updatedSeats = (updatedSeats || _this.seatsInfo)[_this.date || Object.keys(_this.seatsInfo)[0]];
    var redraw = false;
    for (var seatId in updatedSeats) {
      var seat = _this.seats[seatId];
      if (!seat) continue;
      redraw = true;
      var seatInfo = updatedSeats[seatId];
      var status;
      if (seatInfo.chosen) {
        status = Seat.Status.Chosen;
        if (seat.status != status) _this.numberOfChosenSeats++;
      } else {
        if (seat.status == Seat.Status.Chosen) _this.numberOfChosenSeats--;
        if (seatInfo.taken && !seatInfo.chosen) {
          status = Seat.Status.Taken;
        } else if (!seatInfo.taken && !seatInfo.chosen) {
          status = Seat.Status.Available;
        } else if (seatInfo.exclusive) {
          status = Seat.Status.Exclusive;
        }
      }
      seat.setStatus(status);
    }
    if (redraw) this.drawLayer("seats");
  };
  
  this.chooseSeat = function (seat) {
    if (seat.status != Seat.Status.Available) return;
    
    seat.setStatus(Seat.Status.PreChosen);
    
    this.node.emit("chooseSeat", { seatId: seat.id }, function (res) {
      if (!res.ok) seat.setStatus(Seat.Status.Available);
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
    return this.numberOfSeats - this.numberOfChosenSeats;
  };
  
  this.validate = function () {
    this.updateErrorBox();
    return this.getSeatsYetToChoose() < 1;
  };
  
  this.mouseOverSeat = function (seat) {
    this.setCursor("pointer");
  };
  
  this.clickedSeat = function (seat) {
    if (seat) this.chooseSeat(seat);
  };
  
	this.registerEvents = function () {
    $(window).on("beforeunload", function () {
      _this.noErrors = true;
    });
    
    this.node.on("gotSeatingId", function (data) {
      _this.seatingId = data.id;
      _this.delegate.seatChooserGotSeatingId();
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
    
    var eventMappings = [["expired", "Expired"], ["connect_failed", "CouldNotConnect"], ["disconnect", "Disconnected"]];
    $.each(eventMappings, function (i, mapping) {
      _this.node.on(mapping[0], function () {
        if (!_this.noErrors) _this.delegate['seatChooser' + mapping[1]]();
      });
    });
	};
  
  
  this.initSeats();
  
  this.node = io.connect("/seating", {
    "resource": "node",
    "reconnect": false
  });
  
  this.registerEvents();
};


Object.create = Object.create || function (p) {
  function F() {}
  F.prototype = p;
  return new F();
};

SeatChooser.prototype = Object.create(Seating.prototype);
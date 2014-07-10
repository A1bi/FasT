//= require socket.io-client/dist/socket.io.min
//= require KineticJS/kinetic.min

function Seat(id, block, number, pos, delegate) {
  this.id = id;
  this.block = block;
  this.delegate = delegate;
  this.selected = false;
  this.status = Seat.Status.Default;
  this.shape;
  this.group;
  this.text;
  var _this = this;
  
  this.setSelected = function (sel) {
    this.selected = sel;
    this.setStatus(Seat.Status[sel ? "Selected" : "Default"]);
  };
  
  this.getShapeScope = function () {
    switch (this.status) {
    case Seat.Status.Selected:
    case Seat.Status.Default:
      return this.block;
    default:
      return Seat;
    }
  };
  
  this.renderStatusShape = function () {
    var shapeScope = this.getShapeScope();
    if (shapeScope.statusShapeQueues[this.status]) {
      shapeScope.statusShapeQueues[this.status].push(this);
      return;
    } else {
      shapeScope.statusShapeQueues[this.status] = [this];
    }
    Seat.statusShapesToRender++;
    
    var defaultOptions = {
      width: Seat.size[0],
      height: Seat.size[1],
      strokeEnabled: false,
      stroke: "white",
      dashEnabled: false,
      cornerRadius: 2,
      opacity: 1,
      shadowEnabled: true,
      shadowColor: "silver",
      shadowOffset: [1, 1],
      shadowBlur: 3
    };
    if (this.block) defaultOptions['fill'] = this.block.color;
    
    var options;
    switch (this.status) {
    case Seat.Status.Default:
      options = {};
      break;
    case Seat.Status.PreAvailable:
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
        dash: [5, 5],
        dashEnabled: true
      };
      break;
    }
  
    new Kinetic.Rect(defaultOptions).setAttrs(options).toImage({
      x: -Seat.cacheOffset[0],
      y: -Seat.cacheOffset[1],
      width: Seat.cacheSize[0],
      height: Seat.cacheSize[1],
      callback: (function (status) {
        return function (image) {
          shapeScope.statusShapes[status] = new Kinetic.Image({
            image: image
          });
          for (var i = 0, numberOfSeats = shapeScope.statusShapeQueues[status].length; i < numberOfSeats; i++) {
            shapeScope.statusShapeQueues[status][i]['updateStatusShape']();
          }
          console.log("Rendered seat status shape '" + status + "'");
          delete shapeScope.statusShapeQueues[status];
          if (--Seat.statusShapesToRender < 1) {
            for (var i = 0, cLength = Seat.statusShapeRenderingCallbacks.length; i < cLength; i++) {
              Seat.statusShapeRenderingCallbacks[i]();
            }
          }
        };
      })(this.status)
    });
  };
  
  this.getStatusShape = function () {
    return this.getShapeScope().statusShapes[this.status];
  };
  
  this.updateStatusShape = function () {
    if (!this.getStatusShape()) {
      this.renderStatusShape();
      return;
    }
    
    if (this.shape) this.shape.destroy();
    this.shape = this.getStatusShape().clone();
    this.group.add(this.shape);
    this.shape.draw().moveToBottom();
  };
  
  this.updateNumber = function () {
    var textColor;
    switch (this.status) {
    case Seat.Status.PreChosen:
    case Seat.Status.Chosen:
      textColor = "red";
      break;
    default:
      textColor = "white";
    }
    this.text.fill(textColor);
  };
  
  this.setStatus = function (status) {
    if (this.status == status) return;
    this.status = status;
    this.updateStatusShape();
    this.updateNumber();
  };
  
  this.toggleNumber = function (toggle) {
    this.text.visible(toggle);
  };
  
  
  this.group = new Kinetic.Group({
    x: pos[0],
    y: pos[1],
    width: Seat.size[0],
    height: Seat.size[1],
    name: "seat",
    seat: this
  });
  if (this.delegate) {
    this.group.on("click touchend", function () {
      if (_this.delegate.clickedSeat) _this.delegate.clickedSeat(_this);
    }).on("mouseover", function () {
      if (_this.delegate.mouseOverSeat) _this.delegate.mouseOverSeat(_this);
    }).on("mouseout", function () {
      _this.delegate.setCursor();
    });
  }
  
  var fontSize = Seat.size[1] * 0.6;
  this.text = new Kinetic.Text({
    y: (Seat.cacheSize[1] - fontSize) / 2,
    width: Seat.cacheSize[0],
    fontSize: fontSize,
    fontFamily: "Arial",
    fill: "white",
    align: "center",
    text: number,
    visible: false
  });
  this.group.add(this.text);
};

Seat.Status = {
  Default: 0,
  Available: 1,
  Chosen: 2,
  PreChosen: 3,
  Taken: 4,
  Exclusive: 5,
  Selected: 6,
  PreAvailable: 7
};

Seat.setSize = function (size) {
  Seat.size = size;
  Seat.cacheOffset = [5, 5];
  Seat.cacheSize = [Seat.size[0] + Seat.cacheOffset[0] * 2, Seat.size[1] + Seat.cacheOffset[1] * 2];
};

Seat.statusShapes = {};
Seat.statusShapeQueues = {};
Seat.statusShapesToRender = 0;
Seat.statusShapeRenderingCallbacks = [];

function SeatBlock(id, color, delegate) {
  this.id = id;
  this.color = color;
  this.delegate = delegate;
  this.seats = [];
  this.group = new Kinetic.Group();
  this.statusShapes = {};
  this.statusShapeQueues = {};
  
  this.addSeat = function (id, number, pos) {
    var seat = new Seat(id, this, number, pos, this.delegate);
    this.seats.push(seat);
    this.group.add(seat.group);
    return seat;
  };
};

function Seating(container) {
  this.container = container;
  this.maxHorizontalGridCells = 150;
  this.seatSizeFactor = 2.8;
  this.gridCellSize;
  this.stage = null;
  this.layers = {};
  this.seats = {};
  this.viewOptions = {
    numbers: false,
    underlay: false,
    photo: false
  };
  var _this = this;
  
  this.getGridPos = function (pos) {
    return { position_x: Math.round(pos.x / this.gridCellSize), position_y: Math.round(pos.y / this.gridCellSize) };
  };
  
  this.initSeats = function (seatCallback, afterCallback) {
    $.getJSON("/api/seats", function (data) {
      
      for (var i = 0, bLength = data.blocks.length; i < bLength; i++) {
        var blockInfo = data.blocks[i];
        var block = new SeatBlock(blockInfo.id, blockInfo.color, _this);
        _this.addToLayer("seats", block.group);
        
        for (var j = 0, sLength = blockInfo.seats.length; j < sLength; j++) {
          var seatInfo = blockInfo.seats[j];
          var pos = [seatInfo.position[0] * _this.gridCellSize, seatInfo.position[1] * _this.gridCellSize];
          var seat = block.addSeat(seatInfo.id, seatInfo.number, pos);
          seat.toggleNumber(_this.viewOptions['numbers']);
          _this.seats[seatInfo.id] = seat;
          if (seatCallback) seatCallback(seat);
        }
        
      }
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
  
  this.drawSeatsLayer = function () {
    this.layers['seats'].cache();
    this.drawLayer("seats");
  };
  
  this.drawKey = function (exclusive) {
    var rectPadding = 10;
    var keyRectWidth = this.stage.width() * 0.8, keyRectHeight = keyLayerHeight - rectPadding * 2;
    var padding = 7, xPos = 10;
    var drawText = function (text, bold) {
      var fontSize = keyRectHeight * 0.4;
      var keyText = new Kinetic.Text({
        x: xPos,
        y: (keyRectHeight - fontSize) / 2,
        text: text,
        fontSize: fontSize,
        fill: "black"
      });
      if (bold) keyText.fontStyle("bold");
      keyGroup.add(keyText);
      xPos += keyText.width() + 7;
    };
    
    if (!this.layers['key']) {
      this.addLayer("key", {
        width: keyRectWidth,
        height: keyLayerHeight,
        x: (this.stage.width() - keyRectWidth) / 2,
        y: rectPadding
      });
      this.layers['key'].setAttr("originalX", this.layers['key'].position().x);
      
      Seat.statusShapeRenderingCallbacks.push(function () {
        _this.drawLayer("key");
      });
    } else {
      this.layers['key'].removeChildren();
    }
    
    var keyGroup = this.addToLayer("key", new Kinetic.Group({
      width: keyRectWidth,
      height: keyRectHeight
    }));
  
    var keyRect = new Kinetic.Rect({
      width: keyRectWidth,
      height: keyRectHeight,
      fill: "white",
      strokeEnabled: true,
      stroke: "gray",
      strokeWidth: 1.2,
      cornerRadius: 8
    });
    keyGroup.add(keyRect);
    
    drawText("Sitzplatz-Legende", true);
    
    var statuses = [Seat.Status.Available, Seat.Status.Taken, Seat.Status.Chosen];
    if (exclusive) statuses.push(Seat.Status.Exclusive);
    for (var i = 0; i < statuses.length; i++) {
      keyGroup.add(new Kinetic.Line({
        points: [xPos, keyRectHeight, xPos, 0],
        stroke: "gray",
        strokeWidth: 1
      }));
      xPos += 1 + padding;
    
      var seatScale = .8;
      var seat = new Seat(null, null, 0, [xPos, (keyRectHeight - Seat.cacheSize[1] * seatScale) / 2]);
      keyGroup.add(seat.group);
      seat.setStatus(statuses[i]);
      seat.group.setScale({ x: seatScale, y: seatScale });
      xPos += Seat.cacheSize[0] * seatScale + 3;
      
      var text;
      switch (statuses[i]) {
      case Seat.Status.Available:
        text = "noch frei";
        break;
      case Seat.Status.Taken:
        text = "besetzt";
        break;
      case Seat.Status.Chosen:
        text = "Ihre Auswahl";
        break;
      case Seat.Status.Exclusive:
        text = "exklusiv für Sie verfügbar";
      }
      drawText(text);
    }
    
    xPos += 3;
    keyGroup.width(xPos);
    keyRect.width(xPos);
    keyGroup.position({ x: (keyRectWidth - xPos) / 2 });
    
    this.drawLayer("key");
  };
  
  
  var isBig = this.container.is(".big");
  var planBox = this.container.find(".plan");
  this.stage = new Kinetic.Stage({
    container: planBox.get(0),
    width: planBox.width(),
    height: planBox.height(),
    draggable: isBig,
    dragBoundFunc: function (pos) {
      var newPos = {
        x: Math.min(0, Math.max(planBox.width() * -0.8, pos.x)),
        y: 0
      };
      if (_this.layers['key']) _this.layers['key'].position({ x: -newPos.x + _this.layers['key'].getAttr("originalX") });
      return newPos;
    }
  })
  .on("dragstart", function () {
    _this.setCursor("move");
  })
  .on("dragend", function () {
    _this.setCursor();
  });
  
  var drawStage = this.container.is(".stage");
  var drawKey = this.container.is(".key");
  var seatsLayerHeight = this.stage.height();
  var stageLayerHeight = 0;
  var keyLayerHeight = 0;
  if (drawStage) {
    stageLayerHeight = 80;
    seatsLayerHeight -= stageLayerHeight;
  }
  if (drawKey) {
    keyLayerHeight = 50;
    seatsLayerHeight -= keyLayerHeight;
  }
  this.addLayer("seats", {
    width: this.stage.width() * ((isBig) ? 1.8 : 1),
    height: seatsLayerHeight,
    y: keyLayerHeight
  });
  
  this.gridCellSize = this.layers['seats'].width() / this.maxHorizontalGridCells;
  Seat.setSize([this.gridCellSize * this.seatSizeFactor, this.gridCellSize * this.seatSizeFactor]);
  Seat.statusShapeRenderingCallbacks.push(function () {
    _this.drawSeatsLayer();
  });
  
  if (drawStage) {
    var stageRectWidth = this.layers['seats'].width() * 0.95, stageRectHeight = 40;
    this.addLayer("stage", {
      width: stageRectWidth,
      height: stageLayerHeight,
      x: (this.layers['seats'].width() - stageRectWidth) / 2,
      y: seatsLayerHeight + keyLayerHeight + (stageLayerHeight - stageRectHeight) / 2
    });
    this.addToLayer("stage", new Kinetic.Rect({
      width: stageRectWidth,
      height: stageRectHeight,
      fill: "#43a1ca",
      cornerRadius: 7
    }));
    var fontSize = stageRectHeight * 0.6;
    var stageText = this.addToLayer("stage", new Kinetic.Text({
      y: (stageRectHeight - fontSize) / 2,
      text: "Bühne",
      fontSize: fontSize,
      fontFamily: "Qlassik",
      fill: "white"
    }));
    stageText.position({ x: (stageRectWidth - stageText.width()) / 2 });
    this.drawLayer("stage");
  }
  
  if (drawKey) {
    this.drawKey(false);
  }
  
  this.addLayer("background", {
    width: this.layers['seats'].width(),
    height: this.stage.height(),
    y: keyLayerHeight
  }).moveToBottom();
  
  if (this.container.is(".background")) {
    this.background = this.addToLayer("background", new Kinetic.Rect({
      width: this.layers['background'].width(),
      height: this.layers['background'].height(),
      fillLinearGradientStartPoint: { x: 0, y: this.layers['seats'].height() * 0.4 },
      fillLinearGradientEndPoint: { x: 50, y: this.layers['seats'].height() },
      fillLinearGradientColorStops: [0, "white", 1, "#E1F0FF"]
    }));
  }
  
  var viewChooser = this.container.find(".viewChooser");
  if (viewChooser.length) {
    var viewChooserCallback = function ($this) {
      $this.addClass("selected").siblings().removeClass("selected");
      var viewType = $this.data("type");
      _this.viewOptions['numbers'] = _this.viewOptions['underlay'] = viewType == "numbers_and_underlay";
      _this.viewOptions['photo'] = viewType == "photo";
      _this.toggleNumbers(_this.viewOptions['numbers']);
      _this.layers['seats'].visible(!_this.viewOptions['photo']);
      _this.drawSeatsLayer();
      _this.underlayImage.visible(_this.viewOptions['underlay']);
      _this.photoUnderlayImage.visible(_this.viewOptions['photo']);
      _this.drawLayer("background");
    };
    
    var underlay = new Image();
    underlay.src = "/uploads/seating_underlay.png";
    underlay.onload = function () {
      _this.underlayImage = _this.addToLayer("background", new Kinetic.Image({
        image: underlay,
        width: _this.layers['seats'].width(),
        height: _this.layers['seats'].width() / underlay.width * underlay.height,
        visible: false
      }));
      
      var photo = new Image();
      photo.src = "/uploads/seating_photo.jpg";
      photo.onload = function () {
        _this.photoUnderlayImage = _this.addToLayer("background", new Kinetic.Image({
          image: photo,
          width: _this.layers['seats'].width(),
          height: _this.layers['seats'].width() / photo.width * photo.height,
          visible: false
        }));
        
        viewChooser.find("a").click(function (event) {
          event.preventDefault();
          var $this = $(this);
          if ($this.is(".selected")) return;
          viewChooserCallback($this);
        });
        viewChooserCallback(viewChooser.find(".selected"));
      };
    };
  }
  this.drawLayer("background");
};

function SeatingStandalone(container) {
  Seating.call(this, container);
  
  this.initSeats(function (seat) {
    seat.toggleNumber(true);
    seat.updateStatusShape();
  });
};

function SeatingEditor(container) {
  Seating.call(this, container);
  
  this.selecting = false;
  this.selectedSeats = [];
  this.selectedSeatsGroup = [];
  var _this = this;
  
  this.saveSeatsInfo = function () {
    var seats = {};
    for (var i = 0, sLength = this.selectedSeats.length; i < sLength; i++) {
      var seat = this.selectedSeats[i];
      var pos = _this.getGridPos(seat.group.position());
      seats[seat.id] = pos;
    }
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
    
    for (var i = 0, sLength = this.selectedSeats.length; i < sLength; i++) {
      this.selectedSeats[i].group.moveTo(this.selectedSeatsGroup);
    }
    
    _this.drawSeatsLayer();
  };
  
  this.mouseOverSeat = function (seat) {
    this.setCursor(seat.selected ? "move" : "pointer");
  };
  
  this.clickedSeat = function (seat) {
    var index = this.selectedSeats.indexOf(seat);
    var selected = false, cursor;
    if (index != -1 && this.selecting) {
      this.selectedSeats.splice(index, 1);
    } else {
      if (!this.selecting) {
        for (var i = 0, sLength = this.selectedSeats.length; i < sLength; i++) {
          this.selectedSeats[i].setSelected(false);
        }
        this.selectedSeats.length = 0;
      }
      if (seat) {
        this.selectedSeats.push(seat);
        selected = true;
        cursor = "move";
      }
    }
    if (seat) {
      seat.setSelected(selected);
      this.setCursor(cursor);
    }
    this.updateSelectedSeats();
  };
  
  
  this.initSeats(function (seat) {
    seat.toggleNumber(true);
    seat.updateStatusShape();
  });
  
  this.layers['background'].on("mouseup touchend", function () {
    _this.clickedSeat();
  });
  
  this.selectedSeatsGroup = this.addToLayer("seats", new Kinetic.Group({
    draggable: true,
    dragBoundFunc: function (pos) {
      var stagePos = _this.stage.position();
      return {
        x: Math.floor((pos.x - stagePos.x) / _this.gridCellSize) * _this.gridCellSize + stagePos.x,
        y: Math.floor(pos.y / _this.gridCellSize) * _this.gridCellSize
      };
    }
  }))
  .on("dragstart", function () {
    _this.layers['seats'].clearCache();
  })
  .on("dragend", function () {
    _this.relocateSelectedSeats();
    _this.saveSeatsInfo();
    _this.drawSeatsLayer();
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
    if (!this.date) return;
    console.log("Updating seating plan");
    updatedSeats = (updatedSeats || _this.seatsInfo)[_this.date];
    var redraw = false;
    for (var seatId in updatedSeats) {
      var seat = _this.seats[seatId];
      if (!seat) continue;
      redraw = true;
      var seatInfo = updatedSeats[seatId];
      var status;
      if (seatInfo.chosen) {
        status = Seat.Status.Chosen;
        if (seat.status != status && seat.status != Seat.Status.PreAvailable) _this.numberOfChosenSeats++;
      } else {
        if (seat.status == Seat.Status.Chosen || seat.status == Seat.Status.PreAvailable) _this.numberOfChosenSeats--;
        if (seatInfo.taken && !seatInfo.chosen) {
          status = Seat.Status.Taken;
        } else if (seatInfo.exclusive) {
          status = Seat.Status.Exclusive;
        } else if (!seatInfo.taken && !seatInfo.chosen) {
          status = Seat.Status.Available;
        }
      }
      seat.setStatus(status);
    }
    if (redraw) this.drawSeatsLayer();
  };
  
  this.chooseSeat = function (seat) {
    var originalStatus = seat.status;
    var allowedStatuses = [Seat.Status.Available, Seat.Status.Exclusive, Seat.Status.Chosen];
    if (allowedStatuses.indexOf(originalStatus) == -1) return;
    
    var newStatus = (originalStatus == Seat.Status.Chosen) ? Seat.Status.PreAvailable : Seat.Status.PreChosen;
    seat.setStatus(newStatus);
    
    this.node.emit("chooseSeat", { seatId: seat.id }, function (res) {
      if (!res.ok) seat.setStatus(originalStatus);
      _this.updateErrorBoxIfVisible();
    });
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
    return this.numberOfSeats - this.numberOfChosenSeats;
  };
  
  this.validate = function () {
    this.updateErrorBox();
    return this.getSeatsYetToChoose() < 1;
  };
  
  this.mouseOverSeat = function (seat) {
    this.setCursor((seat.status == Seat.Status.Taken) ? null : "pointer");
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
    for (var i = 0, eLength = eventMappings.length; i < eLength; i++) {
      var mapping = eventMappings[i];
      _this.node.on(mapping[0], (function (event) {
        return function () {
          if (!_this.noErrors) _this.delegate['seatChooser' + event]();
        };
      })(mapping[1]));
    }
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

SeatingStandalone.prototype = Object.create(Seating.prototype);
SeatingEditor.prototype = Object.create(Seating.prototype);
SeatChooser.prototype = Object.create(Seating.prototype);

$(window).load(function () {
  $(".seating").each(function () {
    var $this = $(this), klass;
    if ($this.is(".editor")) {
      klass = SeatingEditor;
    } else if ($this.is(".standalone")) {
      klass = SeatingStandalone;
    }
    if (klass) new klass($this);
  });
});
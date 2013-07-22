//= require socket.io-client/dist/socket.io.min.js

function Seating(container) {
  this.maxCells = { x: 185, y: 80 };
  this.sizeFactors = { x: 3.5, y: 3 };
  this.grid = null;
  this.selecting = false;
  this.container = container;
  this.scroller = this.container.find(".scroller");
  this.seats = this.container.find(".ticketing_seat");
  this.callbacks = { selected: function () {} }
  var _this = this;
  
  this.calculateGridCells = function (parent) {
    this.grid = [parent.width() / this.maxCells.x, parent.height() / this.maxCells.y];
  };
  
  this.getGridPos = function (pos) {
    return { position_x: Math.round(pos.left / this.grid[0]), position_y: Math.round(pos.top / this.grid[1]) };
  };
  
  this.changedPos = function (event, ui) {
    var id = ui.helper.data("id");
    $.ajax(_this.container.data("update-url") + id, {
      method: "PUT",
      data: {
        seat: _this.getGridPos(ui.position)
      }
    });
  };
  
  this.dragging = function (event, ui) {
    ui.position.left = Math.floor(ui.position.left / _this.grid[0]) * _this.grid[0];
    ui.position.top = Math.floor(ui.position.top / _this.grid[1]) * _this.grid[1];
  };
  
  this.initDraggables = function (seat) {
    this.scroller.addClass("draggable");
    
    (seat || this.seats).draggable({
      containment: "parent",
      drag: this.dragging,
      stop: this.changedPos
    });
  };
  
  this.initSelectables = function (callback) {
    this.callbacks.selected = callback;
    
    this.scroller.addClass("selectable");
    
    $(document).keydown(function (event) {
      _this.toggleSelecting(event, true);
    })
    .keyup(function (event) {
      _this.toggleSelecting(event, false);
    });
      
    this.scroller.click(function (event) {
      var seat = $(event.target);
      if (!seat.is(".ticketing_seat")) {
        seat = seat.parents(".ticketing_seat");
      }
      var isSeat = seat.is(".ticketing_seat");
      if (!isSeat || !_this.selecting) {
        _this.seats.removeClass("selected");
      }
      if (isSeat) {
        seat.toggleClass("selected");
      }
      
      var seats = _this.seats.filter(".selected"),
          ids = [];
      seats.each(function () {
        ids.push($(this).data("id"));
      });
      
      _this.callbacks.selected(seats, ids);
    });
  };
  
  this.toggleSelecting = function (event, toggle) {
    if (event.which == 91) {
      this.selecting = toggle;
      this.scroller.toggleClass("selecting", toggle);
    }
  };
  
  this.reload = function () {
    $.getJSON(location.href + ".json", function (response) {
      if (response.ok) {
        _this.scroller.html(response.html);
        _this.seats = $(_this.seats.selector);
        _this.initSeats();
      }
    });
  };
  
  this.initSeats = function () {
    var sizes = { x: this.grid[0] * this.sizeFactors.x, y: this.grid[1] * this.sizeFactors.y };
    
    this.seats.each(function () {
      var item = $(this);
      item.css({
        left: item.data("grid-x") * _this.grid[0],
        top: item.data("grid-y") * _this.grid[1],
        width: sizes.x,
        height: sizes.y
      });
    });
  };
  
  this.calculateGridCells(this.scroller);
  this.initSeats();

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
	var _this = this;
  
  this.updateSeats = function (seats) {
    for (var dateId in seats) {
      this.allSeats[dateId] = this.allSeats[dateId] || {};
      for (var seatId in seats[dateId]) {
        var seat = this.allSeats[dateId][seatId] = this.allSeats[dateId][seatId] || {};
        var seatInfo = seats[dateId][seatId];
        seat.taken = seatInfo.t;
        seat.chosen = seatInfo.c;
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
        .toggleClass("available", !seat.taken && !seat.chosen);
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
    var number = this.getSeatsYetToChoose(), direction;
    if (number > 0) {
      togglePluralText(this.errorBox, number, "error");
      direction = "Down";
    } else {
      direction = "Up";
    }
    this.errorBox["slide" + direction].call(this.errorBox);
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
      _this.node.on(mapping[0], function () { _this.delegate['seatChooser' + mapping[1]](); });
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

SeatChooser.prototype = Object.create(Seating.prototype);
function Seating(container) {
  this.maxCells = { x: 100, y: 60 };
  this.sizeFactors = { x: 3.5, y: 3 };
  this.grid = null;
  this.selecting = false;
  this.container = container;
  this.seats = this.container.find(".ticketing_seat");
  this.callbacks = { selected: function () {} }
  var _this = this;
  
  this.calculateGridCells = function (parent) {
    this.grid = [parent.width() / this.maxCells.x, parent.height() / this.maxCells.y];
  };
  
  this.getGridPos = function (pos) {
    return { position_x: Math.floor(pos.left / this.grid[0]), position_y: Math.floor(pos.top / this.grid[1]) };
  };
  
  this.changedPos = function (event, ui) {
    var id = ui.helper.data("id");
    $.ajax(ui.helper.parent().data("update-url") + id, {
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
    (seat || this.seats).draggable({
      containment: "parent",
      drag: this.dragging,
      stop: this.changedPos
    });
  };
  
  this.initSelectables = function (callback) {
    this.callbacks.selected = callback;
    
    $(document).keydown(function (event) {
      _this.toggleSelecting(event, true);
    })
    .keyup(function (event) {
      _this.toggleSelecting(event, false);
    });
      
    this.container.click(function (event) {
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
      
      _this.callbacks.selected(_this.seats.filter(".selected"));
    });
  };
  
  this.toggleSelecting = function (event, toggle) {
    if (event.which == 91) {
      this.selecting = toggle;
      this.container.toggleClass("selecting", toggle);
    }
  };
  
  this.reload = function () {
    $.getJSON(location.href + ".json", function (response) {
      if (response.ok) {
        _this.container.html(response.html);
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
  
  this.calculateGridCells(this.container);
  this.initSeats();

};
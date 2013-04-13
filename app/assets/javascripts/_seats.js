function Seating(container, draggable) {
  this.maxCells = { x: 100, y: 60 };
  this.sizeFactors = { x: 3.5, y: 3 };
  this.grid = null;
  var _this = this;
  
  this.calculateGridCells = function (parent) {
    this.grid = [Math.floor(parent.width() / this.maxCells.x), Math.floor(parent.height() / this.maxCells.y)];
  };
  
  this.getGridPos = function (ui) {
    var pos = ui.position;
    return { position_x: Math.floor(pos.left / this.grid[0]), position_y: Math.floor(pos.top / this.grid[1]) };
  };
  
  this.changedPos = function (event, ui) {
    var id = ui.helper.data("id");
    $.ajax(ui.helper.parent().data("edit-url") + id, {
      method: "PUT",
      data: {
        seat: _this.getGridPos(ui)
      }
    });
  };
  
  this.initDraggables = function (seats) {
    seats.draggable({
      containment: "parent",
      grid: this.grid,
      stop: this.changedPos
    });
  };
  
  this.initSeats = function (seats) {
    var _this = this;
    var sizes = { x: this.grid[0] * this.sizeFactors.x, y: this.grid[1] * this.sizeFactors.y };
    
    seats.each(function () {
      var item = $(this);
      item.css({
        left: item.data("grid-x") * _this.grid[0],
        top: item.data("grid-y") * _this.grid[1],
        width: sizes.x,
        height: sizes.y
      });
    });
  };
  
  this.calculateGridCells(container);
    
  var seats = container.find(".ticketing_seat");
  this.initSeats(seats);
  if (draggable) this.initDraggables(seats);

};
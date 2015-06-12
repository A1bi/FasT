//= require ./_seating
//= require ./base

function TicketTransfer(container) {
  this.seatingId;
  this.box = container;
  this.dateSelect = this.box.find("select");
  this.tickets = this.box.data("tickets");
  var _this = this;
  
  this.date = function () {
    return this.dateSelect.val();
  };
  
  this.updateDate = function () {
    this.chooser.setDateAndNumberOfSeats(this.date(), this.tickets.length, function () {
      
    });
  };
  
  this.makeRequest = function (action, method, callback) {
    $.ajax({
      url: this.box.data(action + "-path"),
      dataType: "json",
      method: method,
      data: {
        ticket_ids: this.tickets,
        date_id: this.date(),
        seatingId: this.seatingId
      },
      complete: callback
    });
  };
  
  this.seatChooserIsReady = function () {
    this.updateDate();
    this.makeRequest("init", "post", function (res) {
      if (res.ok) {
        
      }
    });
  };
  
  this.seatChooserGotSeatingId = function (event) {
    this.seatingId = this.chooser.seatingId;
  };
  
  this.seatChooserDisconnected = function () {
    alert("Die Verbindung zum Server wurde unterbrochen.");
  };
  
  this.seatChooserCouldNotConnect = function () {
    alert("Derzeit ist keine Umbuchung möglich.");
  };
  
  this.seatChooserExpired = function () {
    alert("Die Sitzung ist abgelaufen.");
  };
  
  this.returnToOrder = function () {
    window.location = this.box.data("order-path");
  };
  
  
  this.chooser = new SeatChooser($(".seating"), this);
  
  this.dateSelect.change(function () {
    _this.updateDate();
  });
  
  var buttons = this.box.find(".submit button");
  buttons.first().click(function () {
    _this.returnToOrder();
  });
  
  buttons.last().click(function () {
    if (_this.chooser.validate()) {
      if (confirm($(this).data("confirm"))) {
        _this.makeRequest("update", "patch", function (data) {
          if (data.responseJSON.ok) {
            _this.returnToOrder();
          }
        });
      }
    } else {
      $("body").animate({ scrollTop: _this.box.position().top });
    }
  });
}

$(window).load(function () {
  var transferBox = $(".transfer");
  if (transferBox.length) new TicketTransfer(transferBox);
});
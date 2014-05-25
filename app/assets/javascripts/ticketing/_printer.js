//= require spin.js/dist/spin.min

function TicketPrinter() {
  var _this = this;
  
  this.notifyHelper = function (cmd, options) {
    var url = TicketPrinter.urlScheme + "://" + cmd;
    if (options) url += "!" + options
    window.location.href = url;
  };
  
  this.printTickets = function (path) {
    this.notifyHelper("print", path);
  };
  
  this.openHelperSettings = function () {
    this.notifyHelper("settings");
  };
  
  this.showPrintNotification = function (path, permanent) {
    if (!this.notification) {
      this.notification = $(".print-notification");
      var opts = {
        lines: 13,
        length: 8,
        width: 3,
        radius: 9,
        color: "white"
      };
      this.spinner = new Spinner(opts);
    }
    
    if (this.notification.is(":visible")) return;
    
    this.notification.find("a").prop("href", path);
    this.spinner.spin(this.notification.find(".spinner").get(0));
    this.notification.fadeIn();
    
    if (!permanent) {
      setTimeout(function () {
        _this.notification.fadeOut(function () {
          _this.spinner.stop();
        });
      }, 20000);
    }
  };
  
  this.printTicketsWithNotification = function (path, permanent) {
    this.printTickets(path);
    this.showPrintNotification(path, permanent);
  };
};

TicketPrinter.urlScheme = "fastprint";
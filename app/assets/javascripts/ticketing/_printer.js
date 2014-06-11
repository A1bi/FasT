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
  
  this.showPrintNotification = function (path) {
    if (!this.notification) {
      this.notification = $(".print-notification");
      this.notification.find("a.dismiss").click(function (e) {
        _this.notification.fadeOut();
        e.preventDefault();
      });
      this.spinnerBox = this.notification.find(".spinner");
      var opts = {
        lines: 13,
        length: 8,
        width: 3,
        radius: 9,
        color: "white"
      };
      this.spinner = new Spinner(opts);
    }
    
    this.notification.find("a.restart").off().click(function (e) {
      _this.printTickets(path);
      _this.showSpinner(true);
      e.preventDefault();
    });
    
    if (this.notification.is(":visible")) return;
    
    this.notification.find("a.printable").prop("href", path);
    this.showSpinner();
    this.notification.fadeIn();
  };
  
  this.showSpinner = function (fadeIn) {
    this.spinner.spin(this.spinnerBox.get(0));
    this.spinnerBox.fadeIn();
    
    setTimeout(function () {
      _this.spinnerBox.fadeOut(function () {
        _this.spinner.stop();
      });
    }, 5000);
  };
  
  this.printTicketsWithNotification = function (path) {
    this.printTickets(path);
    this.showPrintNotification(path);
  };
};

TicketPrinter.urlScheme = "fastprint";
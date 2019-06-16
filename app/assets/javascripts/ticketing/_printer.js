function TicketPrinter() {
  var _this = this;

  this.notifyHelper = function (cmd, options) {
    var url = TicketPrinter.urlScheme + "://" + cmd;
    if (options) url += "/" + options
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
      this.spinner = this.notification.find(".spinner");
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
    this.spinner.fadeIn();

    setTimeout(function () {
      _this.spinner.fadeOut();
    }, 5000);
  };

  this.printTicketsWithNotification = function (path) {
    this.printTickets(path);
    this.showPrintNotification(path);
  };
};

TicketPrinter.urlScheme = "fastprint";

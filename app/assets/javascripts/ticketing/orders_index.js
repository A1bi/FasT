//= require ./base
//= require ./_printer

$(function () {
  var printer = new TicketPrinter();

  $('#print-test').on('confirm:complete', function (e) {
    e.preventDefault();
    printer.printTickets('uploads/muster.pdf');
  });

  $('#print-settings').click(function (e) {
    e.preventDefault();
    printer.openHelperSettings();
  });
});

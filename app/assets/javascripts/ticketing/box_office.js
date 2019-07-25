//= require ./_seating

function BoxOfficeSeating() {
  this.setDateAndNumberOfSeats = function (dateId, number) {
    this.chooser.setDateAndNumberOfSeats(dateId, number);
  };

  this.reset = function () {
    this.chooser.reset();
  };

  this.validate = function () {
    return this.chooser.validate();
  };

  this.seatChooserIsReady = function () {
    this.postMessage({
      event: 'becameReady',
      socketId: this.chooser.socketId
    });
  };

  this.seatChooserDisconnected = function () {
    this.reinit();
  };

  this.seatChooserCouldNotConnect = function () {
    this.reinit();
  };

  this.seatChooserCouldNotReconnect = function () {
    this.reinit();
  };

  this.seatChooserIsReconnecting = function () {
    this.connecting();
  };

  this.init = function () {
    this.chooser = new SeatChooser(seatingBox, this, false, true);
  };

  this.reinit = function () {
    this.connecting();

    clearTimeout(this.reinitTimeout);
    this.reinitTimeout = setTimeout(this.init.bind(this), 1000);
  };

  this.connecting = function () {
    this.postMessage({ event: 'connecting' });
  };

  this.postMessage = function (data) {
    if (!window.webkit) return;

    window.webkit.messageHandlers.seating.postMessage(data);
  };

  var seatingBox = $('.seating');
  this.init();
}

$(function () {
  window.seating = new BoxOfficeSeating();
});

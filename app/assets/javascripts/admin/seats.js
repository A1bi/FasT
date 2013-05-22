//= require _seats

$(function () {
  var seatingBox = $(".seating")
  var seating = new Seating(seatingBox);
  var numberInput = $(".new_seat input");
  var newSeats = $(".new_seat .ticketing_seat");
  
  function updateNewSeatNumber() {
    newSeats.each(function () {
      $(".number", this).html(numberInput.val());
      $(this).attr("data-number", numberInput.val());
    });
  }
  
  var seatTemplate = seatingBox.find(".ticketing_seat").first();
  $(".new_seat .ticketing_seat")
  .draggable({
    revert: "invalid",
    appendTo: "#seats",
    containment: "#seats",
    helper: "clone",
    scroll: false,
    cursorAt: { left: 1 }
  })
  .css({
    width: seatTemplate.width(),
    height: seatTemplate.height()
  });
  
  seatingBox.droppable({
    accept: ".draggable",
    tolerance: "fit",
    drop: function (event, ui) {
      var newSeat = $(ui.helper).clone().removeClass("draggable");
      var seatingPos = $(this).position();
      
      newSeat.css({ left: ui.position.left - seatingPos.left, top: ui.position.top - seatingPos.top });
      $(this).append(newSeat);
      
      var pos = seating.getGridPos(newSeat.position());
      $.ajax(seatingBox.data("create-url"), {
        method: "POST",
        data: {
          seat: {
            row: 0,
            number: newSeat.data("number"),
            block_id: newSeat.data("block"),
            position_x: pos.position_x,
            position_y: pos.position_y
          }
        },
        success: function (response) {
          if (response.ok) {
            newSeat.data("id", response.id);
            seating.initDraggables(newSeat);
      
            numberInput.val(parseInt(numberInput.val()) + 1);
            updateNewSeatNumber();
          } else {
            newSeat.fadeOut(400, function () {
              $(this).remove();
            });
          }
        }
      });
    }
  });
  
  numberInput.change(function () {
    $(this).val(function (index, val) {
      return parseInt(val) || 1;
    });
    updateNewSeatNumber();
  });
  
  newSeats.addClass("draggable");
  
  updateNewSeatNumber();
  seating.initDraggables();
  seating.initSelectables();
});

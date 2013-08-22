//= require _seats

$(function () {
  var seatingBox = $(".seating"),
      seating = new Seating(seatingBox),
      numberInput = $(".new_seat input"),
      newSeats = $(".new_seat .ticketing_seat"),
      editSeats = $(".edit_seats"),
      selectedSeats, selectedSeatIds;
  
  function updateNewSeatNumber() {
    newSeats.each(function () {
      $(".number", this).html(numberInput.val());
      $(this).attr("data-number", numberInput.val());
    });
  }
  
  function updateSelectedSeats(method, attrs) {
    var data = {
      seat: attrs,
      ids: selectedSeatIds
    };
    
    $.ajax(seatingBox.data("update-multiple-url"), {
      method: method,
      data: data,
      success: function () {
        seating.reload();
      }
    });
  }
  
  seating.enableViewLayers("numbers");
  
  if ($(".hl").data("edit")) {
    seating.initDraggables();
    seating.initSelectables(function (seats, ids) {
      selectedSeats = seats;
      selectedSeatIds = ids;
      var selection = selectedSeats.length > 0;
      editSeats.toggle(selection);
    
      if (selection) {
        var numberField = editSeats.find("input");
        if (selectedSeats.length == 1) {
          numberField.val(selectedSeats.eq(0).data("number")).removeAttr("disabled");
        } else {
          numberField.val("").attr("disabled", "disabled");
        }
      }
    });
    
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
  
    numberInput
    .change(function () {
      $(this).val(function (index, val) {
        return parseInt(val) || 1;
      });
      updateNewSeatNumber();
    })
    .click(function () {
      $(this).val("");
    });
  
    editSeats.find("input, select").change(function () {
      var $this = $(this),
          attr;
      if ($this.is("input")) {
        selectedSeats.find(".number").html($this.val());
        attr = "number";
      } else {
        attr = "block_id";
      }
      var attrs = {};
      attrs[attr] = $this.val();

      updateSelectedSeats("PUT", attrs);
    });
  
    editSeats.find("a").click(function (event) {
      if (confirm($(this).data("confirm-msg"))) {
        updateSelectedSeats("DELETE");
      }
    
      event.preventDefault();
    });
  
    newSeats.addClass("draggable");
  
    updateNewSeatNumber();
  }
});

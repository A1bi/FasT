//= require _seats

$(function () {
  var seatingBox = $(".seating"),
      reservationBox = $(".reservation"),
      seating = new Seating(seatingBox),
      selectedSeats, selectedSeatIds;
  
  seating.initSelectables(function (seats, ids) {
    selectedSeats = seats;
    selectedSeatIds = ids;
    var selection = selectedSeats.length > 0;
    reservationBox.toggle(selection);
    
    if (selection) {
      $("#group option").removeAttr("selected").first().attr("selected", "selected");
    }
  });
  
  reservationBox.find("select").change(function () {
    $this = $(this);
    if ($this.val() == "new") {
      $this.hide();
      $this.next("#new_group_name").show();
    }
  });
  
  reservationBox.find("form").submit(function () {
    $("<input>").attr("type", "hidden").attr("name", "seats").val(selectedSeatIds).appendTo(this);
  });
});

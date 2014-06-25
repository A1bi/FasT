//= require ./_seating
//= require Chart.js/Chart.min

$(function () {
  $(".chooser span").click(function () {
    $(this).addClass("selected").siblings().removeClass("selected");
    $(".stats *").stop(true, false);
    var tableClass = "." + $(this).data("table");
    $(".stats .table:visible").not(tableClass).slideUp(600, function () {
      $(this).siblings(tableClass).slideDown();
    });
  });
  
  var seatingBoxes = $(".seating");
  if (seatingBoxes.length) {
    $.getJSON(seatingBoxes.first().data("additional-path"), function (data) {
      seatingBoxes.each(function () {
        var $this = $(this);
        var dateSeats = data.seats[$this.data("date")];
        var seating = new Seating($this);
        seating.initSeats(function (seat) {
          var status = dateSeats[seat.id] ? Seat.Status.Available : Seat.Status.Taken;
          seat.setStatus(status);
        });
      });
    });
  }
  
  var dailyStatsCanvas = $("#daily_stats");
  if (dailyStatsCanvas.length) {
    dailyStatsCanvas.prop("width", dailyStatsCanvas.parent().width());
    
    $.getJSON(dailyStatsCanvas.data("chart-data-path"), function (data) {
      $.each(data.datasets, function (i, dataset) {
        var color = dailyStatsCanvas.siblings(".key").find("span").eq(i).css("color"),
            rgb = /^rgb\(([\d]{1,3}), ?([\d]{1,3}), ?([\d]{1,3})\)$/i.exec(color),
            rgba = "rgba(" + rgb[1] + "," + rgb[2] + "," + rgb[3] + ", .7)",
            fillColor = (i == 0) ? "rgba(0, 0, 0, 0)" : rgba,
            strokeColor = (i == 0) ? color : "#d7f1fb";
        $.extend(dataset, {
          fillColor: fillColor,
          strokeColor: strokeColor,
          pointColor: color,
          pointStrokeColor: "white"
        });
      });
      
      var options = {
        bezierCurve: false,
        datasetStrokeWidth: 1
      };
      new Chart(dailyStatsCanvas.get(0).getContext("2d")).Line(data, options);
    });
  }
});
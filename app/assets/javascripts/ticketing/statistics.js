//= require ./_seating
//= require chart.js/dist/Chart

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
      if (!data) return;

      seatingBoxes.each(function () {
        var $this = $(this);
        var dateSeats = data.seats[$this.data("date")];
        var seating = new Seating($this);
        seating.initSeats(function (seat) {
          var status;
          switch (dateSeats[seat.id]) {
          case 2:
            status = Seat.Status.Exclusive
            break;
          case 1:
            status = Seat.Status.Available
            break;
          default:
            status = Seat.Status.Taken
          }
          seat.setStatus(status);
        });
      });
    });
  }

  var dailyStatsCanvas = $("#daily_stats");
  if (dailyStatsCanvas.length) {
    dailyStatsCanvas.prop("width", dailyStatsCanvas.parent().width());

    $.getJSON(dailyStatsCanvas.data("chart-data-path"), function (data) {
      var chartColors = {
        red: 'rgb(255, 99, 132)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)'
      };
      var colorOrder = ['green', 'red', 'blue'];

      data.datasets.forEach(function (dataset, index) {
        dataset.backgroundColor = chartColors[colorOrder[index]];
        dataset.borderColor = dataset.backgroundColor;
      });

      new Chart(dailyStatsCanvas, {
        type: 'line',
        data: data,
        options: {
          datasets: {
            line: {
              lineTension: 0
            }
          },
          tooltips: {
            mode: 'index'
          },
          scales: {
            yAxes: [{
              stacked: true,
              scaleLabel: {
                display: true,
                labelString: 'Verkaufte Tickets'
              }
            }]
          }
        }
      });
    });
  }
});

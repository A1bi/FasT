import '../../../javascripts/ticketing/_seating'
import Chart from 'chart.js'
import $ from 'jquery'

$(() => {
  $('.chooser span').click(async event => {
    const $this = $(event.currentTarget);
    $this.addClass('selected').siblings().removeClass('selected');
    $(".stats *").stop(true, false);

    const tableClass = "." + $this.data("table");
    const tables = $(".stats .table:visible");
    await tables.not(tableClass).slideUp(600).promise();
    tables.siblings(tableClass).slideDown();
  });

  const seatingBoxes = $('.seating');
  if (seatingBoxes.length) {
    $.getJSON(seatingBoxes.first().data('additional-path'), data => {
      if (!data) return;

      for (let box of seatingBoxes) {
        const $box = $(box);
        const dateSeats = data.seats[$box.data('date')];
        var seating = new Seating($box);
        seating.initSeats(seat => {
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
      }
    });
  }

  const dailyStatsCanvas = $('#daily_stats');
  if (dailyStatsCanvas.length) {
    dailyStatsCanvas.prop('width', dailyStatsCanvas.parent().width());

    $.getJSON(dailyStatsCanvas.data('chart-data-path'), data => {
      const chartColors = {
        red: 'rgb(255, 99, 132)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)'
      };
      const colorOrder = ['green', 'red', 'blue'];

      data.datasets.forEach((dataset, index) => {
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

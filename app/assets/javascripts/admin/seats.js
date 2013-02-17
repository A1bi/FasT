function getGridPos(actual, grid) {
	return Math.round(actual / grid) * grid;
}

function updateDraggables() {
	var grid = [5, 7];
	
	$(".seating .tickets_seat").draggable({
		containment: "parent",
		grid: grid,
		stop: function (event, ui) {
			var id = ui.helper.data("id");
			var parent = ui.helper.parent();
			$.ajax(parent.data("edit-url") + id, {
				method: "PUT",
				data: {
					seat: {
						position_x: ui.position.left / parent.outerWidth() * 100,
						position_y: ui.position.top / parent.outerHeight() * 100
					}
				}
			});
		}
	})
	
	.each(function () {
		var item = $(this);
		item.css({
			left: getGridPos(item.position().left, grid[0]),
			top: getGridPos(item.position().top, grid[1])
		});
	});
}

$(function () {
	updateDraggables();
});
//= require ./_seating

$(window).load(function () {
  var container = $(".seating.editor");
  if (container.length) new SeatingEditor(container);
});

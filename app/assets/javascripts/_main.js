function togglePluralText(box, number) {
  var plural = number != 1;
  box.toggleClass("plural", plural).toggleClass("singular", !plural);
  box.find(".number span").text(number);
}

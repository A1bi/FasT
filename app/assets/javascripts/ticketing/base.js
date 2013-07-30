$(function () {
  $("tbody.hover tr").click(function () {
    $this = $(this);
    var checkbox = $this.find(":checkbox");
    if (checkbox.length) {
      checkbox.prop("checked", !checkbox.prop("checked"));
    } else {
      window.location = $this.data("path");
    }
  });
  
  $("tr :checkbox").click(function (event) {
    event.stopPropagation();
    $this = $(this);
    if ($this.parent().is("th")) {
      $this.parents("table").find("tbody :checkbox").prop("checked", $this.prop("checked"));
    }
  });
  
  $(".seating").each(function () {
    new Seating($(this));
  });
});
$(function () {
  function toggle_actions($checkbox) {
    var table = $checkbox.parents("table");
    table.find("td.actions *").prop("disabled", table.find(":checkbox:checked").length < 1);
  }
  
  $("tbody.hover tr").click(function () {
    $this = $(this);
    var checkbox = $this.find(":checkbox");
    if (checkbox.length) {
      if ($this.is(":not(.cancelled)")) {
        checkbox.prop("checked", !checkbox.prop("checked"));
        toggle_actions($this);
      }
    } else {
      window.location = $this.data("path");
    }
  });
  
  $("tr :checkbox").click(function (event) {
    event.stopPropagation();
    $this = $(this);
    if ($this.parent().is("th")) {
      $this.parents("table").find("tbody tr:not(.cancelled) :checkbox").prop("checked", $this.prop("checked"));
    }
    toggle_actions($this);
  });
});
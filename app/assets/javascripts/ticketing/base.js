$(function () {
  function toggle_actions($checkbox) {
    var table = $checkbox.parents("table");
    table.find("td.actions *").prop("disabled", table.find(":checkbox:checked").length < 1);
  }
  
  var tableRows = $("tbody.hover tr, th").click(function () {
    var $this = $(this);
    var checkbox = $this.find(":checkbox");
    if (checkbox.length) {
      if ($this.is(":not(.cancelled)")) {
        checkbox.prop("checked", !checkbox.prop("checked"));
        toggle_actions($this);
      }
    } else if ($this.data("path")) {
      window.location = $this.data("path");
    }
  });
  tableRows.find("a").click(function (event) {
    if (!$(this).data('confirm')) {
      event.stopPropagation();
    }
  });
  tableRows.find(":checkbox").click(function (event) {
    event.stopPropagation();
    var $this = $(this);
    if ($this.parent().is("th")) {
      $this.parents("table").find("tbody tr:not(.cancelled) :checkbox").prop("checked", $this.prop("checked"));
    }
    toggle_actions($this);
  });
});
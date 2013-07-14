//= require _seats
//= require spin

function Step(name, delegate) {
  this.name = name;
  this.box = $(".stepCon." + this.name);
  this.info = { api: {}, internal: {} };
  this.delegate = delegate;
  
  this.registerEvents();
}

Step.prototype = {
  moveIn: function (animate) {
    this.willMoveIn();
    
    animate = animate !== false;
    
    this.box.show();
    var props = { left: "0%" };
    if (animate) {
      this.box.animate(props);
    } else {
      this.box.css(props);
    }
    this.delegate.setNextBtnText();
    this.resizeDelegateBox(animate);
    this.toggleFormFields(true);
  },
  
  moveOut: function (left) {
    this.box.animate({left: 100 * ((left) ? -1 : 1) + "%"}, function () {
      $(this).hide();
    });
  },
  
  resizeDelegateBox: function (animated) {
    this.delegate.resizeStepBox(this.box.outerHeight(true), animated);
  },
  
  slideToggle: function (obj, toggle) {
    var _this = this;
    var props = {
      step: function () {
        _this.resizeDelegateBox(false);
      }
    };
    
    if (toggle) {
      obj.slideDown(props);
    } else {
      obj.slideUp(props);
    }
  },
  
  toggleFormFields: function (toggle) {
    this.box.find("input, select, textarea").attr("disabled", !toggle);
  },
  
  updateInfo: function () {
    var _this = this;
    $.each(this.box.find("form").serializeArray(), function () {
      var pattern = new RegExp(_this.name + "\\[([a-z_]+)\\]");
      if (pattern.test(this.name)) {
        _this.info.api[this.name.replace(pattern, "$1")] = this.value;
      }
    });
  },
  
  getStepInfo: function (stepName) {
    return this.delegate.info[stepName].internal;
  },
  
  validate: function () {
    return true;
  },
  
  afterValidate: function (response) {
    var _this = this;
    this.box.find("tr").removeClass("error");
    if (!response.ok) {
      this.toggleFormFields(true);
      
      $.each(response.errors, function (key, error) {
        _this.box.find("#" + _this.name + "_" + key).parents("tr").addClass("error").find(".msg").html(error);
      });
      this.resizeDelegateBox(true);
    }
  },
  
  willMoveIn: function () {},
  
  registerEvents: function () {},
  
  formatCurrency: function (value) {
    return value.toFixed(2).toString().replace(".", ",");
  }
};

function DateStep(delegate) {
  var _this = this;
  
  this.registerEvents = function () {
    this.box.find("li").click(function () {
      _this.choseDate($(this));
    });
    this.box.find("select").change(function () {
      _this.choseNumber($(this));
    });
  };
  
  Step.call(this, "date", delegate);
  
  this.info.api.tickets = {};
  
  this.getTypeTotal = function ($typeBox) {
    return $typeBox.data("price") * $typeBox.find("select").val();
  };
  
  this.updateTotal = function () {
    var total = 0;
    _this.info.internal.numberOfTickets = 0;
    this.box.find(".number tr").each(function () {
      if ($(this).is(".ticketing_ticket_type")) {
        var $this = $(this);
        _this.info.internal.numberOfTickets += parseInt($this.find("select").val());
        total += _this.getTypeTotal($this);
      } else {
        $(this).find(".total span").html(_this.formatCurrency(total));
      }
    });
    
    this.delegate.toggleNextBtn(this.info.internal.numberOfTickets > 0);
  };
  
  this.choseDate = function ($this) {
    $this.parent().find(".selected").removeClass("selected");
    $this.addClass("selected");
    this.slideToggle(this.box.find("div.number"), true);
    
    this.info.api.date = $this.data("id");
    this.info.internal.localizedDate = $this.text();
  };
  
  this.choseNumber = function ($this) {
    var typeBox = $this.parents("tr");
    typeBox.find("td.total span").html(this.formatCurrency(this.getTypeTotal(typeBox)));
    this.updateTotal();
    
    this.info.api.tickets[typeBox.data("id")] = parseInt($this.val());
  };
}

function SeatsStep(delegate) {
  this.chooser = null;
  var _this = this;
  
  this.validate = function () {
    return this.chooser.validate();
  };
  
  this.willMoveIn = function () {
    var info = this.delegate.getStepInfo("date");
    this.chooser.setDateAndNumberOfSeats(info.api.date, info.internal.numberOfTickets);
    togglePluralText(this.box.find(".note"), info.internal.numberOfTickets, "note");
  };
  
  this.registerEvents = function () {
    this.box.show();
    this.chooser = new SeatChooser(this.box.find(".seating"));
    this.box.hide();
  };
  
  Step.call(this, "seats", delegate);
}

function AddressStep(delegate) {
  var _this = this;
  
  this.validate = function () {
    this.updateInfo();
    Step.prototype.validate.call(this);
  };
  
  this.willMoveIn = function () {
    this.delegate.toggleNextBtn(true);
  };
  
  Step.call(this, "address", delegate);
}

function PaymentStep(delegate) {
  var _this = this;
  
  this.registerEvents = function () {
    this.box.find("[name=method]").click(function () {
      _this.info.api.method = $(this).val();
      _this.slideToggle(_this.box.find(".charge"), _this.info.api.method == "charge");
      _this.delegate.toggleNextBtn(true);
    });
  };
  
  this.validate = function () {
    this.updateInfo();
    Step.prototype.validate.call(this);
  };
  
  this.willMoveIn = function () {
    this.delegate.toggleNextBtn(this.info.api.method);
  };
  
  Step.call(this, "payment", delegate);
}

function ConfirmStep(delegate) {
  var _this = this;
  
  this.registerEvents = function () {
    this.box.find(".checkboxes :checkbox").click(function () {
      _this.info.api[$(this).attr("name")] = $(this).is(":checked");
      _this.delegate.toggleNextBtn(_this.info.api.accepted);
    });
    
    // this.delegate.observeOrder("date", function (info) {
//       var total = 0;
//       $.each(info.tickets, function (typeId, number) {
//         var typeBox = _this.box.find("#ticketing_ticket_type_" + typeId);
//         typeBox.find(".number").text(number || 0);
//         var totalBox = typeBox.find(".total");
//         var subtotal = totalBox.data("price") * number;
//         totalBox.find("span").text(_this.formatCurrency(subtotal));
//         total += subtotal;
//       });
//       _this.box.find(".total .total span").text(_this.formatCurrency(total));
//       _this.box.find(".date").text(info.localizedDate);
//     });
//     $.each(["address", "payment"], function (i, key) {
//       _this.delegate.observeOrder(key, function (info) {
//         if (key == "payment") {
//           _this.box.find(".payment").removeClass("transfer charge").addClass(info.method);
//         }
//         _this.updateSummary(info, key);
//       });
//     });
  };
  
  this.updateSummary = function (info, part) {
    $.each(info, function (key, value) {
      _this.box.find("."+part+" ."+key).text(value);
    });
  };
  
  this.willMoveIn = function () {
    this.delegate.toggleNextBtn(this.delegate.retail || this.info.accepted);
    this.delegate.setNextBtnText("bestellen");
  };
  
  Step.call(this, "confirm", delegate);
  
  this.info.newsletter = true;
}

function FinishStep(delegate) {
  var _this = this;
  var opts = {
    lines: 13,
    length: 20,
    width: 10,
    radius: 30,
    trail: 60,
    shadow: true
  };
  this.spinner = new Spinner(opts);
  
  this.registerEvents = function () {
    // this.delegate.observeOrder("payment", function (info) {
    //   _this.box.find(".tickets").toggle(info.payment == "charge");
    // });
    
    // this.delegate.node.on("orderPlaced", function (res) {
    //   _this.spinner.stop();
    //   
    //   if (!res.ok) return;
    //   
    //   _this.box.find(".success").show();
    //   if (_this.delegate.retail) {
    //     _this.box.find(".total span").text(_this.formatCurrency(res.order.total));
    //     _this.box.find(".printable_link").attr("href", res.order.printable_path);
    //   }
    // });
  };
  
  this.willMoveIn = function () {
    this.delegate.toggleNextBtn(false);
    this.delegate.hideOrderControls();
    this.spinner.spin(this.box.get(0));
  };
  
  Step.call(this, "finish", delegate);
}

var ordering = new function () {
  this.stepBox = null;
  this.currentStepIndex = -1;
  this.currentStep = null;
  this.steps = [];
  this.expirationBox = null;
  this.expirationTimer = null;
  this.aborted = false;
  var _this = this;
  
  this.toggleBtn = function (btn, toggle, style_class) {
    style_class = style_class || "disabled";
    $(".btn."+btn).toggleClass(style_class, !toggle);
  };
  
  this.toggleNextBtn = function (toggle, style_class) {
    this.toggleBtn("next", toggle, style_class);
  };
  
  this.setNextBtnText = function (text) {
    $(".btn.next .action").text(text || "weiter");
  };
  
  this.hideOrderControls = function () {
    $(".progress, .btns").slideUp();
  };
  
  this.goNext = function ($this) {
    if ($this.is(".disabled")) return;
    
    if ($this.is(".prev")) {
      this.showPrev();
      
    } else {
      if (this.currentStep.validate()) {
        this.showNext(true);
      } else {
        $("body").animate({ scrollTop: this.stepBox.position().top });
      }
    }
  };
  
  this.showNext = function (animate) {
    if (this.currentStep) {
      this.currentStep.moveOut(true);
    }
    this.updateCurrentStep(1);
    this.moveInCurrentStep(animate);
  };
  
  this.showPrev = function () {
    this.currentStep.moveOut(false);
    this.updateCurrentStep(-1);
    this.moveInCurrentStep();
  };
  
  this.showModalAlert = function (msg) {
    if (this.aborted) return;
    this.aborted = true;
    this.stepBox.find(".modal_alert").fadeIn().find("li").first().html(msg);
    this.hideOrderControls();
  };
  
  this.updateCurrentStep = function (inc) {
    this.currentStepIndex += inc;
    this.currentStep = this.steps[this.currentStepIndex];
  };
  
  this.updateProgress = function() {
    if (this.currentStepIndex == this.steps.length - 1) return;
    
    var progressBox = $(".progress");
    progressBox.find(".current").removeClass("current");
    var current = progressBox.find(".step." + this.currentStep.name).addClass("current");
    progressBox.find(".bar").css("left", current.position().left);
  };
  
  this.moveInCurrentStep = function (animate) {
    this.currentStep.moveIn(animate);
    this.toggleBtn("prev", this.currentStepIndex > 0);
    this.updateProgress();
  };
  
  this.resizeStepBox = function (height, animated) {
    var props = { height: height };
    
    if (animated) {
      this.stepBox.animate(props);
    } else {
      this.stepBox.css(props);
    }
  };
  
  this.getStepInfo = function (stepName) {
    var info;
    $.each(this.steps, function () {
      if (this.name == stepName) {
        info = this.info;
        return;
      }
    });
    return info;
  };
  
  this.updateExpirationCounter = function (seconds) {
    if (seconds < 0) return;
    this.expirationBox.find("span").text(seconds);
    this.expirationTimer = setTimeout(function () {
      _this.updateExpirationCounter(--seconds);
    }, 1000);
  };
  
  this.killExpirationTimer = function () {
    this.expirationBox.slideUp();
    clearTimeout(this.expirationTimer);
  };
  
  this.registerEvents = function () {
    $(".btn").click(function () {
      _this.goNext($(this));
    });
    
    // this.node.on("orderPlaced", function (response) {
    //   if (response.ok) {
    //     _this.aborted = true;
    //   } else {
    //     _this.showModalAlert("Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.");
    //   }
    // });
    // 
    // this.node.on("aboutToExpire", function (data) {
    //   _this.expirationBox.slideDown();
    //   _this.updateExpirationCounter(data.secondsLeft);
    // });
    // 
    // this.node.on("expired", function () {
    //   _this.expirationBox.slideUp();
    //   _this.showModalAlert("Ihre Sitzung ist abgelaufen.<br />Wenn Sie möchten, können Sie den Bestellvorgang erneut starten.");
    // });
    // 
    // this.node.on("disconnect", function () {
    //   _this.showModalAlert("Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.");
    // });
  };
  
  $(function () {
    _this.stepBox = $(".stepBox");
    _this.expirationBox = $(".expiration");
    
    _this.retail = !!$(".retail").length;
    var steps = (_this.retail) ? [DateStep, SeatsStep, ConfirmStep, FinishStep] : [DateStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep, FinishStep];
    
    $(".progress .step").css({ width: 100 / (steps.length - 1) + "%" });
    
    _this.registerEvents();
    
    $.each(steps, function (index, stepClass) {
      stepClass.prototype = Step.prototype;
      var step = new stepClass(_this);
      _this.steps.push(step);
      
      $(".progress .step." + step.name).show();
    });
  
    _this.showNext(false);
  });
}
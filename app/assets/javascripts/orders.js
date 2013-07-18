//= require _seats
//= require node-validator/validator-min
//= require spin

function Step(name, delegate) {
  this.name = name;
  this.box = $(".stepCon." + this.name);
  this.info = { api: {}, internal: {} };
  this.delegate = delegate;
  
  var _this = this;
  this.validator = new Validator();
  this.validator.error = function (msg) {
    _this.showErrorOnField(msg[0], msg[1]);
    this._errors.push(msg);
    return this;
  };
  this.validator.foundErrors = function () {
    return this._errors.length > 0;
  };
  this.validator.resetErrors = function () {
    this._errors = [];
  };
  
  this.registerEvents();
}

Step.prototype = {
  moveIn: function (animate) {
    this.delegate.setNextBtnText();
    this.willMoveIn();
    
    animate = animate !== false;
    
    this.box.show();
    var props = { left: "0%" };
    if (animate) {
      this.box.animate(props);
    } else {
      this.box.css(props);
    }
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
  
  updateInfoFromFields: function () {
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
  
  getFieldWithKey: function (key) {
    return this.box.find("#" + this.name + "_" + key);
  },
  
  validate: function () {
    return true;
  },
  
  validateFields: function (proc) {
    this.box.find("tr").removeClass("error");
    this.validator.resetErrors();
    proc.call(this);
    
    var errors = this.validator.foundErrors();
    if (errors) {
      this.resizeDelegateBox(true);
    } else {
      this.updateInfoFromFields();
    }
    
    return !errors;
  },
  
  getValidatorCheckForField: function (key, msg) {
    return this.validator.check(this.getFieldWithKey(key).val(), [key, msg]);
  },
  
  showErrorOnField: function (key, msg) {
    this.getFieldWithKey(key).parents("tr").addClass("error").find(".msg").html(msg);
  },
  
  willMoveIn: function () {},
  
  registerEvents: function () {}
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
  this.info.internal.ticketTotals = {};
  
  this.formatCurrency = function (value) {
    return value.toFixed(2).toString().replace(".", ",");
  };
  
  this.getTypeTotal = function ($typeBox, number) {
    return $typeBox.data("price") * $typeBox.find("select").val();
  };
  
  this.updateTotal = function () {
    var total = 0;
    this.info.internal.numberOfTickets = 0;
    this.box.find(".number tr").each(function () {
      var $this = $(this);
      if ($this.is(".ticketing_ticket_type")) {
        _this.info.internal.numberOfTickets += parseInt($this.find("select").val());
        total += _this.getTypeTotal($this);
      } else {
        var formattedTotal = _this.formatCurrency(total);
        _this.info.internal.total = formattedTotal;
        $this.find(".total span").html(formattedTotal);
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
    var typeBox = $this.parents("tr"), typeId = typeBox.data("id");
    var total = this.formatCurrency(this.getTypeTotal(typeBox));
    typeBox.find("td.total span").html(total);
    
    this.info.api.tickets[typeId] = parseInt($this.val());
    this.info.internal.ticketTotals[typeId] = total;
    this.updateTotal();
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
    return this.validateFields(function () {
      $.each(["first_name", "last_name", "phone"], function () {
        _this.getValidatorCheckForField(this, "Bitte füllen Sie dieses Feld aus.").notEmpty();
      });
    
      this.getValidatorCheckForField("plz", "Bitte geben Sie eine korrekte Postleitzahl an.").isInt().len(5, 5);
      this.getValidatorCheckForField("email", "Bitte geben Sie eine korrekte e-mail-Adresse an.").isEmail();
    });
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
      _this.slideToggle(_this.box.find(".charge"), _this.methodIsCharge());
      _this.delegate.toggleNextBtn(true);
    });
  };
  
  this.validate = function () {
    if (this.methodIsCharge()) {
      return this.validateFields(function () {
        this.getValidatorCheckForField("name", "Bitte geben Sie den Kontoinhaber an.").notEmpty();
        this.getValidatorCheckForField("number", "Bitte geben Sie eine korrekte Kontonummer an.").isInt().len(1, 12);
        this.getValidatorCheckForField("blz", "Bitte geben Sie eine korrekte Bankleitzahl an.").isInt().len(8, 8);
        this.getValidatorCheckForField("bank", "Bitte geben Sie den Namen der Bank an.").notEmpty();
      });
    }
    
    return true;
  };
  
  this.methodIsCharge = function () {
    return this.info.api.method == "charge";
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
  };
  
  Step.call(this, "confirm", delegate);
  
  this.info.api.newsletter = true;
  
  this.updateSummary = function (info, part) {
    $.each(info, function (key, value) {
      _this.box.find("."+part+" ."+key).text(value);
    });
  };
  
  this.willMoveIn = function () {
    this.delegate.toggleNextBtn(this.delegate.retail || this.info.accepted);
    this.delegate.setNextBtnText("bestellen");
    
    var dateInfo = this.delegate.getStepInfo("date");
    this.box.find(".date").text(dateInfo.internal.localizedDate);
    
    this.box.find(".tickets tr").each(function () {
      var typeBox = $(this);
      var number, total;
      if (typeBox.is(".total")) {
        number = dateInfo.internal.numberOfTickets;
        total = dateInfo.internal.total;
      } else {
        var typeId = typeBox.find("td").first().data("id");
        number = dateInfo.api.tickets[typeId];
        total = dateInfo.internal.ticketTotals[typeId];
      }
      typeBox.find(".single .number").text(number || 0);
      typeBox.find(".total span").text(total || 0);
      if (typeBox.is(".total")) togglePluralText(typeBox.find(".single"), number, "single");
    });
    
    $.each(["address", "payment"], function () {
      var info = _this.delegate.getStepInfo(this);
      if (!info) return;
      var box = _this.box.find("."+this);
      if (this == "payment") {
        box.removeClass("transfer charge").addClass(info.api.method);
      }
      $.each(info.api, function (key, value) {
        box.find("."+key).text(value);
      });
    });
  };
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
    var payInfo = this.delegate.getStepInfo("payment");
    if (payInfo) this.box.find(".tickets").toggle(payInfo.api.method == "charge");
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
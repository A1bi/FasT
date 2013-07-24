//= require _seats
//= require node-validator/validator-min
//= require spin.js/dist/spin.min

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
  
  shouldBeSkipped: function () {
    return false;
  },
  
  nextBtnEnabled: function () {
    return true;
  },
  
  registerEvents: function () {},
  
  formatCurrency: function (value) {
    return value.toFixed(2).toString().replace(".", ",");
  }
};

function DateStep(delegate) {
  var _this = this;
  this.couponBox;
  
  this.registerEvents = function () {
    this.couponBox = this.box.find(".coupon");
    this.box.find("li").click(function () {
      _this.choseDate($(this));
    });
    this.box.find("select").change(function () {
      _this.choseNumber($(this));
    });
    this.couponBox.find("input[type=text]").keyup(function (event) {
      if (event.which == 13) _this.redeemCoupon();
    });
    this.couponBox.find("input[type=submit]").click(function () {
      _this.redeemCoupon();
    });
  };
  
  Step.call(this, "date", delegate);
  
  this.info.api.tickets = {};
  this.info.internal.ticketTotals = {};
  
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
        _this.info.internal.formattedTotal = formattedTotal;
        _this.info.internal.total = total;
        $this.find(".total span").html(formattedTotal);
      }
    });
    
    this.delegate.updateNextBtn();
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
  
  this.redeemCoupon = function () {
    this.delegate.toggleModalSpinner(true);
    $.post(this.couponBox.data("redeem-url"), {
      code: this.couponBox.find("input[name=code]").val(),
      seatingId: this.delegate.getStepInfo("seats").api.seatingId
    }).always(function (res) { _this.codeRedeemed(res); });
  };
  
  this.codeRedeemed = function (res) {
    var msg;
    if (res.ok === false) {
      if (res.error == "expired") {
        msg = "Dieser Code ist leider abgelaufen.";
      } else {
        msg = "Dieser Code ist nicht gültig.";
      }
    } else if (!res.ok) {
       msg = "Es ist ein unbekannter Fehler aufgetreten.";
    } else {
      var couponField = this.couponBox.find("input[name=code]");
      this.info.api.couponCode = couponField.val();
      
      this.info.internal.exclusiveSeats = res.seats;
      $.each(res.ticket_types, function (typeId, number) {
        if (number != 0) {
          var typeBox = _this.box.find("#ticketing_ticket_type_" + typeId).show();
          if (number > 0) {
            typeBox.find("option").slice(number + 1).remove();
          }
        }
      });
      
      msg = "Ihr Code wurde erfolgreich eingelöst.";
      this.couponBox.find("input").attr("disabled", "disabled");
      couponField.blur().val("");
      this.resizeDelegateBox(true);
    }
    
    this.delegate.toggleModalSpinner(false);
    this.couponBox.find(".msg").text(msg).toggleClass("error", !res.ok);
  };
  
  this.willMoveIn = function () {
    this.box.find(".total > span").text(this.formatCurrency(0));
  };
  
  this.nextBtnEnabled = function () {
    return this.info.internal.numberOfTickets > 0;
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
    _this.delegate.toggleModalSpinner(true);
    this.chooser.setDateAndNumberOfSeats(info.api.date, info.internal.numberOfTickets, function () {
      _this.delegate.toggleModalSpinner(false);
    });
    togglePluralText(this.box.find(".note"), info.internal.numberOfTickets, "note");
    this.box.find(".key .exclusiveSeats").toggle(!!info.internal.exclusiveSeats);
  };
  
  this.registerEvents = function () {
    this.box.show();
    this.chooser = new SeatChooser(this.box.find(".seating"), this);
    this.box.hide();
    this.delegate.toggleModalSpinner(true);
  };
  
  this.seatChooserIsReady = function () {
    this.delegate.toggleModalSpinner(false);
  };
  
  this.seatChooserGotSeatingId = function (event) {
    this.info.api.seatingId = this.chooser.seatingId;
  };
  
  this.seatChooserDisconnected = function () {
    this.delegate.showModalAlert("Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.");
  };
  
  this.seatChooserCouldNotConnect = function () {
    this.delegate.showModalAlert("Derzeit ist keine Buchung möglich.<br />Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.");
  };
  
  this.seatChooserExpired = function () {
    this.delegate.expire();
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
    
      if (this.getFieldWithKey("gender").val() < 0) this.showErrorOnField("gender", "Bitte wählen Sie eine Anrede aus.");
      this.getValidatorCheckForField("plz", "Bitte geben Sie eine korrekte Postleitzahl an.").isInt().len(5, 5);
      this.getValidatorCheckForField("email", "Bitte geben Sie eine korrekte e-mail-Adresse an.").isEmail();
    });
  };
  
  Step.call(this, "address", delegate);
}

function PaymentStep(delegate) {
  var _this = this;
  
  this.registerEvents = function () {
    this.box.find("[name=method]").click(function () {
      _this.info.api.method = $(this).val();
      _this.slideToggle(_this.box.find(".charge"), _this.methodIsCharge());
      _this.delegate.updateNextBtn();
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
  
  this.nextBtnEnabled = function () {
    return !!this.info.api.method;
  };
  
  this.shouldBeSkipped = function () {
    return this.delegate.getStepInfo("date").internal.total == 0;
  };
  
  Step.call(this, "payment", delegate);
}

function ConfirmStep(delegate) {
  var _this = this;
  
  this.registerEvents = function () {
    this.box.find(".checkboxes :checkbox").click(function () {
      _this.info.api[$(this).attr("name")] = $(this).is(":checked");
      _this.delegate.updateNextBtn();
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
    this.delegate.setNextBtnText("bestellen");
    
    var dateInfo = this.delegate.getStepInfo("date");
    this.box.find(".date").text(dateInfo.internal.localizedDate);
    
    this.box.find(".tickets tr").show().each(function () {
      var typeBox = $(this);
      var number, total;
      if (typeBox.is(".total")) {
        number = dateInfo.internal.numberOfTickets;
        total = dateInfo.internal.formattedTotal;
      } else {
        var typeId = typeBox.find("td").first().data("id");
        number = dateInfo.api.tickets[typeId];
        if (!number || number < 1) {
          typeBox.hide();
          return;
        }
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
      if (this == "payment" && dateInfo.internal.total > 0) {
        box.removeClass("transfer charge").addClass(info.api.method);
      }
      $.each(info.api, function (key, value) {
        box.find("."+key).text(value);
      });
    });
  };
  
  this.nextBtnEnabled = function () {
    return this.delegate.retail || !!_this.info.api.accepted;
  };
}

function FinishStep(delegate) {
  var _this = this;
  
  this.placeOrder = function () {
    var apiInfo = this.delegate.getApiInfo();
    var orderInfo = {
      date: apiInfo.date.date,
      tickets: apiInfo.date.tickets,
      seatingId: apiInfo.seats.seatingId,
      address: apiInfo.address,
      payment: apiInfo.payment,
      couponCode: apiInfo.date.couponCode
    };
    var info = {
      order: orderInfo,
      web: true,
      retailId: this.delegate.retailId,
      newsletter: apiInfo.confirm.newsletter
    };
    $.post("/api/orders", info)
      .done(function (res) { _this.orderPlaced(res); })
      .fail(function () { _this.error(); });
  };
  
  this.orderPlaced = function (res) {
    this.delegate.toggleModalSpinner(false);
    
    if (!res.ok) {
      this.error();
      return;
    }
    
    this.box.find(".success").show();
    if (this.delegate.retail) {
      this.box.find(".total span").text(this.formatCurrency(res.order.total));
      this.box.find(".printable_link").attr("href", res.order.printable_path);
    }
  };
  
  this.error = function () {
    this.delegate.showModalAlert("Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.");
  };
  
  this.willMoveIn = function () {
    var payInfo = this.delegate.getStepInfo("payment");
    if (payInfo) this.box.find(".tickets").toggle(payInfo.api.method == "charge");
    this.delegate.hideOrderControls();
    this.delegate.toggleModalSpinner(true);
    
    this.placeOrder();
  };
  
  Step.call(this, "finish", delegate);
}

var ordering = new function () {
  this.stepBox;
  this.currentStepIndex = -1;
  this.currentStep;
  this.steps = [];
  this.expirationBox;
  this.expirationTimer = { type: 0, timer: null, times: [300, 60] };
  this.btns;
  this.modalBox;
  this.modalSpinner;
  this.aborted = false;
  var _this = this;
  
  this.toggleBtn = function (btn, toggle, style_class) {
    style_class = style_class || "disabled";
    this.btns.filter("."+btn).toggleClass(style_class, !toggle);
  };
  
  this.toggleNextBtn = function (toggle, style_class) {
    this.toggleBtn("next", toggle, style_class);
  };
  
  this.setNextBtnText = function (text) {
    this.btns.filter(".next").find(".action").text(text || "weiter");
  };
  
  this.updateNextBtn = function () {
    this.toggleNextBtn(this.currentStep.nextBtnEnabled());
  };
  
  this.updateBtns = function () {
    this.toggleBtn("prev", this.currentStepIndex > 0);
    this.updateNextBtn();
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
  
  this.toggleModalBox = function (toggle, callback) {
    return this.modalBox["fade" + (toggle ? "In" : "Out")](callback);
  };
  
  this.toggleModalSpinner = function (toggle) {
    if (toggle) {
      this.toggleNextBtn(false);
      this.toggleBtn("prev", false);
      this.toggleModalBox(true).append(this.modalSpinner.spin().el);
    } else {
      this.updateBtns();
      this.toggleModalBox(false, function () {
        _this.modalSpinner.stop();
      });
    }
  };
  
  this.showModalAlert = function (msg) {
    if (this.aborted) return;
    this.aborted = true;
    this.modalSpinner.stop();
    this.killExpirationTimer();
    this.toggleModalBox(true).find(".messages").show().find("li").first().html(msg);
    this.hideOrderControls();
  };
  
  this.updateCurrentStep = function (inc) {
    do {
      this.currentStepIndex += inc;
      this.currentStep = this.steps[this.currentStepIndex];
    } while (this.currentStep.shouldBeSkipped());
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
    this.updateBtns();
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
  
  this.getApiInfo = function () {
    var info = {};
    $.each(this.steps, function () {
      info[this.name] = this.info.api;
    });
    return info;
  };
  
  this.updateExpirationCounter = function (seconds) {
    if (this.expirationTimer.type == 0 && seconds < 1) {
      this.expirationTimer.type = 1;
      seconds = this.expirationTimer.times[1];
      this.expirationBox.slideDown();
    }
    if (this.expirationTimer.type == 1) {
      if (seconds < 1) {
        this.expire();
        return;
      }
      togglePluralText(this.expirationBox.find("li"), seconds);
    }
    this.expirationTimer.timer = setTimeout(function () {
      _this.updateExpirationCounter(--seconds);
    }, 1000);
  };
  
  this.killExpirationTimer = function () {
    clearTimeout(this.expirationTimer.timer);
    this.expirationBox.slideUp();
  };
  
  this.resetExpirationTimer = function () {
    this.killExpirationTimer();
    if (this.aborted) return;
    this.expirationTimer.type = 0;
    this.updateExpirationCounter(this.expirationTimer.times[0] - this.expirationTimer.times[1]);
  };
  
  this.expire = function () {
    this.showModalAlert("Ihre Sitzung ist abgelaufen.<br />Wenn Sie möchten, können Sie den Bestellvorgang erneut starten.");
  };
  
  this.registerEvents = function () {
    this.btns.click(function () {
      _this.goNext($(this));
    });
    
    $(document).click(function () {
      _this.resetExpirationTimer();
    }).keydown(function () {
      _this.resetExpirationTimer();
    });
    
    var nextBtn = this.btns.filter(".next");
    $(".stepBox input:not(.noKeyCatch)").keyup(function (event) {
      if (event.which == 13) _this.goNext(nextBtn);
    });
  };
  
  $(function () {
    _this.stepBox = $(".stepBox");
    _this.expirationBox = $(".expiration");
    _this.btns = $(".btns .btn");
    _this.modalBox = _this.stepBox.find(".modalAlert");
    
    _this.retailId = $(".retail").data("id");
    _this.retail = !!_this.retailId;
    var steps = (_this.retail) ? [DateStep, SeatsStep, ConfirmStep, FinishStep] : [DateStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep, FinishStep];
    
    $(".progress .step").css({ width: 100 / (steps.length - 1) + "%" });
    var opts = {
      lines: 13,
      length: 20,
      width: 10,
      radius: 30,
      trail: 60,
      shadow: true,
      color: "white"
    };
    _this.modalSpinner = new Spinner(opts);
    
    _this.registerEvents();
    
    $.each(steps, function (index, stepClass) {
      stepClass.prototype = Step.prototype;
      var step = new stepClass(_this);
      _this.steps.push(step);
      
      $(".progress .step." + step.name).show();
    });
  
    _this.showNext(false);
    _this.resetExpirationTimer();
  });
}
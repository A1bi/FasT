//= require ./_seating
//= require ./base
//= require node-validator/validator-min
//= require spin.js/dist/spin.min
//= require ./_printer

function Step(name, delegate) {
  this.name = name;
  this.box = $(".stepCon." + this.name);
  this.info = { api: {}, internal: {} };
  this.delegate = delegate;
  this.foundErrors;
  
  var _this = this;
  this.validator = new Validator();
  this.validator.error = function (msg) {
    _this.showErrorOnField(msg[0], msg[1]);
    return this;
  };
  this.validator.onlyDigits = function() {
    if (!this.str.match(/^\d*$/)) {
        return this.error(this.msg || 'Invalid digit');
    }
    return this;
  };
  this.validator.upperStrip = function () {
    return this.str.toUpperCase().replace(/ /g, "");
  };
  this.validator.isIBAN = function () {
    var parts = this.upperStrip().match(/^([A-Z]{2})(\d{2})([A-Z0-9]{6,30})$/);
    var ok = true;
    if (parts) {
      if (parts[1] == "DE") {
        $.each(parts, function (i, part) {
          parts[i] = part.replace(/\D/g, function (char) {
            return char.charCodeAt(0) - 64 + 9;
          });
        });
        var bban = parts[3] + parts[1] + parts[2];
        var remainder = 0;
        for (var i = 0; i < bban.length; i++) {
          remainder = (remainder + bban.charAt(i)) % 97;
        }
        if (remainder != 1) {
          ok = false;
        }
      }
    } else {
      ok = false;
    }
    if (!ok) return this.error(this.msg || 'Invalid IBAN');
    return this;
  };
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
    
    return obj;
  },
  
  updateInfoFromFields: function () {
    var _this = this;
    $.each(this.box.find("form").serializeArray(), function () {
      var name = this.name.match(/\[([a-z_]+)\]/);
      if (!!name && !/_confirmation$/.test(name[1])) {
        _this.info.api[name[1]] = this.value;
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
  
  validateFields: function (beforeProc, afterProc) {
    this.box.find("tr").removeClass("error");
    this.foundErrors = false;
    beforeProc.call(this);
    
    if (this.foundErrors) {
      this.resizeDelegateBox(true);
    } else {
      this.updateInfoFromFields();
    }
    if (afterProc) afterProc.call(this);
    
    return !this.foundErrors;
  },
  
  getValidatorCheckForField: function (key, msg) {
    return this.validator.check(this.getFieldWithKey(key).val(), [key, msg]);
  },
  
  showErrorOnField: function (key, msg) {
    var field = this.getFieldWithKey(key).parents("tr").addClass("error");
    if (msg) field.find(".msg").html(msg);
    this.foundErrors = true;
  },
  
  willMoveIn: function () {},
  
  shouldBeSkipped: function () {
    return false;
  },
  
  nextBtnEnabled: function () {
    return true;
  },
  
  formatCurrency: function (value) {
    return value.toFixed(2).toString().replace(".", ",");
  },
  
  trackPiwikGoal: function (id, revenue) {
    try {
      _paq.push(['trackGoal', id, revenue]);
    } catch (e) {}
  },

  registerEventAndInitiate: function (elements, event, proc) {
    var callback = function () { proc($(this)); };
    elements[event](callback);
    elements.each(callback);
  }
};

function TicketsStep(delegate) {
  var _this = this;
  this.couponBox;
  
  Step.call(this, "tickets", delegate);
  
  this.info.api.tickets = {};
  this.info.internal = {
    ticketTotals: {},
    exclusiveTicketTypes: []
  };
  
  this.getTypeTotal = function ($typeBox, number) {
    return $typeBox.data("price") * $typeBox.find("select").val();
  };
  
  this.updateTotal = function () {
    var total = 0;
    this.info.internal.numberOfTickets = 0;
    this.box.find(".number tr").each(function () {
      var $this = $(this);
      if ($this.is(".date_ticketing_ticket_type")) {
        _this.info.internal.numberOfTickets += parseInt($this.find("select").val());
        total += _this.getTypeTotal($this);
      } else {
        togglePluralText($this.find("td").first(), _this.info.internal.numberOfTickets);
        var formattedTotal = _this.formatCurrency(total);
        _this.info.internal.formattedTotal = formattedTotal;
        _this.info.internal.total = total;
        $this.find(".total span").html(formattedTotal);
      }
    });
    
    this.delegate.updateNextBtn();
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
    var code = this.couponBox.find("input[name=code]").val();
    if (code == "") return;
    this.delegate.toggleModalSpinner(true);
    $.post(this.couponBox.data("redeem-url"), {
      code: code,
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
      this.info.internal.exclusiveTicketTypes = [];
      $.each(res.ticket_types, function (i, type) {
        var typeBox = _this.box.find("#date_ticketing_ticket_type_" + type.id).toggle(type.number != 0);
        if (type.number > 0) {
          _this.info.internal.exclusiveTicketTypes.push(type.id);
          var options = typeBox.find("option");
          if (options.length - 1 > type.number) {
            options.slice(type.number + 1).remove();
          } else {
            var sampleOption = options.last(), select = sampleOption.parent();
            for (var i = options.length; i <= type.number; i++) {
              sampleOption.clone().text(i).val(i).appendTo(select);
            }
          }
        }
      });
      
      this.trackPiwikGoal(2);
      
      msg = "Ihr Gutschein wurde erfolgreich eingelöst.";
      if (!this.delegate.admin && this.info.internal.exclusiveTicketTypes.length > 0) {
        this.couponBox.find(".ticketTypeNote").show();
      }
      this.couponBox.find("input").attr("disabled", "disabled");
      couponField.blur().val("");
    }
    
    this.delegate.toggleModalSpinner(false);
    var msgBox = this.couponBox.find(".msg .result").text(msg).toggleClass("error", !res.ok).parent();
    if (msgBox.is(":visible")) {
      this.resizeDelegateBox(true);
    } else {
      this.slideToggle(msgBox, true);
    }
  };
  
  this.nextBtnEnabled = function () {
    return this.info.internal.numberOfTickets > 0;
  };
  
  this.validate = function () {
    return !this.askToRedeemCoupon();
  };
  
  this.askToRedeemCoupon = function () {
    if (this.couponField.val()) {
      if (!confirm(this.couponBox.data("confirm-dismiss"))) {
        this.couponField.focus();
        return true;
      }
      this.couponField.val("");
    }
    return false;
  };
  
  this.couponBox = this.box.find(".coupon");
  this.couponField = this.couponBox.find("input[type=text]");
  this.registerEventAndInitiate(this.box.find("select"), "change", function ($this) {
    if (_this.askToRedeemCoupon()) {
      $this.val(0);
    }
    _this.choseNumber($this);
  });
  this.couponField.keyup(function (event) {
    if (event.which == 13) _this.redeemCoupon();
  });
  this.couponBox.find("input[type=submit]").click(function () {
    _this.redeemCoupon();
  });
}

function SeatsStep(delegate) {
  this.chooser = null;
  var _this = this;
  
  this.validate = function () {
    return this.chooser.validate();
  };
  
  this.nextBtnEnabled = function () {
    return !!this.info.api.date;
  };
  
  this.willMoveIn = function () {
    var info = this.delegate.getStepInfo("tickets");
    if (this.numberOfSeats != info.internal.numberOfTickets) {
      this.numberOfSeats = info.internal.numberOfTickets;
      togglePluralText(this.box.find(".note.number_of_tickets"), this.numberOfSeats);
      this.chooser.toggleErrorBox(false);
      this.updateSeatingPlan();
    }
    this.toggleExclusiveSeatsKey(!!info.internal.exclusiveSeats);
  };
  
  this.choseDate = function ($this) {
    if ($this.is(".selected") || $this.is(".disabled")) return;
    $this.parents("table").find(".selected").removeClass("selected");
    $this.addClass("selected");
    
    this.info.api.date = $this.data("id");
    this.info.internal.localizedDate = $this.text();
    this.updateSeatingPlan();
    
    this.slideToggle(this.seatingBox, true);
  };
  
  this.updateSeatingPlan = function () {
    this.delegate.toggleModalSpinner(true);
    this.chooser.setDateAndNumberOfSeats(this.info.api.date, this.numberOfSeats, function () {
      _this.delegate.toggleModalSpinner(false);
    });
  };
  
  this.enableReservationGroups = function () {
    var groups = [];
    this.box.find(".reservationGroups :checkbox").each(function () {
      var $this = $(this);
      if ($this.is(":checked")) groups.push($this.prop("name"));
    });
    
    this.delegate.toggleModalSpinner(true);
    $.post(this.box.find(".reservationGroups").data("enable-url"), {
      groups: groups,
      seatingId: this.delegate.getStepInfo("seats").api.seatingId
    }).always(function (res) {
      _this.delegate.toggleModalSpinner(false);
      _this.toggleExclusiveSeatsKey(!!res.seats);
      _this.resizeDelegateBox();
    });
  };
  
  this.toggleExclusiveSeatsKey = function (toggle) {
    this.chooser.drawKey(toggle);
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
  
  
  this.delegate.toggleModalSpinner(true, true);
  this.seatingBox = this.box.find(".seat_chooser");
  this.box.show();
  this.chooser = new SeatChooser(this.seatingBox.find(".seating"), this);
  this.box.hide();
  this.seatingBox.hide();
  
  this.box.find(".date td").click(function () {
    _this.choseDate($(this));
  });
  this.box.find(".reservationGroups :checkbox").prop("checked", false).click(function () {
    _this.enableReservationGroups();
  });
}

function AddressStep(delegate) {
  var _this = this;
  
  this.validate = function () {
    return this.validateFields(function () {
      if (this.delegate.web) {
        $.each(["first_name", "last_name", "phone"], function () {
          _this.getValidatorCheckForField(this, "Bitte füllen Sie dieses Feld aus.").notEmpty();
        });
    
        if (this.getFieldWithKey("gender").val() < 0) this.showErrorOnField("gender", "Bitte wählen Sie eine Anrede aus.");
        this.getValidatorCheckForField("email_confirmation", "Die e-mail-Adressen stimmen nicht überein.").notEmpty().equals(this.getFieldWithKey("email").val());
      }
      if (this.delegate.web || this.getFieldWithKey("email").val() != "") {
        this.getValidatorCheckForField("email", "Bitte geben Sie eine korrekte e-mail-Adresse an.").isEmail();
      }
      if (this.delegate.web || this.getFieldWithKey("plz").val() != "") {
        this.getValidatorCheckForField("plz", "Bitte geben Sie eine korrekte Postleitzahl an.").onlyDigits().len(5, 5);
      }
    });
  };
  
  Step.call(this, "address", delegate);
}

function PaymentStep(delegate) {
  var _this = this;
  
  this.validate = function () {
    if (this.methodIsCharge()) {
      return this.validateFields(function () {
        this.getValidatorCheckForField("name", "Bitte geben Sie den Kontoinhaber an.").notEmpty();
        this.getValidatorCheckForField("iban", "Die angegebene IBAN ist nicht korrekt. Bitte überprüfen Sie sie noch einmal.").isIBAN();
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
    return this.delegate.getStepInfo("tickets").internal.total == 0;
  };
  
  Step.call(this, "payment", delegate);
  
  
  this.registerEventAndInitiate(this.box.find("[name=method]"), "click", function ($this) {
    if (!$this.is(":checked")) return;
    _this.info.api.method = $this.val();
    _this.slideToggle(_this.box.find(".charge"), _this.methodIsCharge());
    _this.delegate.updateNextBtn();
  });
}

function ConfirmStep(delegate) {
  var _this = this;
  
  Step.call(this, "confirm", delegate);
  
  this.updateSummary = function (info, part) {
    $.each(info, function (key, value) {
      _this.box.find("."+part+" ."+key).text(value);
    });
  };
  
  this.willMoveIn = function () {
    this.delegate.setNextBtnText("bestellen");
    
    var ticketsInfo = this.delegate.getStepInfo("tickets");
    this.box.find(".date").text(this.delegate.getStepInfo("seats").internal.localizedDate);
    
    this.box.find(".tickets tbody tr").show().each(function () {
      var typeBox = $(this);
      var number, total;
      if (typeBox.is(".total")) {
        number = ticketsInfo.internal.numberOfTickets;
        total = ticketsInfo.internal.formattedTotal;
      } else if (typeBox.is(".coupon")) {
        var redeemed = !!ticketsInfo.api.couponCode;
        typeBox.find(".redeemed").addClass(redeemed ? "true" : "false");
      } else {
        var typeId = typeBox.find("td").first().data("id");
        number = ticketsInfo.api.tickets[typeId];
        if ((!number || number < 1) && ticketsInfo.internal.exclusiveTicketTypes.indexOf(typeId) == -1) {
          typeBox.hide();
          return;
        }
        total = ticketsInfo.internal.ticketTotals[typeId];
      }
      typeBox.find(".total span").text(total);
      var single = typeBox.find(".single");
      if (typeBox.is(".total")) {
        togglePluralText(single, number);
      } else {
        if (number == 0) number = "keine";
        single.find(".number").text(number);
      }
    });
    
    $.each(["address", "payment"], function () {
      var info = _this.delegate.getStepInfo(this);
      if (!info) return;
      var box = _this.box.find("."+this);
      if (this == "payment" && ticketsInfo.internal.total > 0) {
        box.removeClass("transfer charge").addClass(info.api.method);
      }
      $.each(info.api, function (key, value) {
        box.find("."+key).text(value);
      });
    });
  };
  
  this.validate = function () {
    return this.validateFields(function () {
      if (this.delegate.web && !this.getFieldWithKey("accepted").is(":checked")) {
        this.showErrorOnField("accepted");
      }
    }, function () {
      this.info.api.newsletter = this.info.api.newsletter == "1";
    });
  };
}

function FinishStep(delegate) {
  var _this = this;
  
  this.placeOrder = function () {
    var apiInfo = this.delegate.getApiInfo();
    var orderInfo = {
      date: apiInfo.seats.date,
      tickets: apiInfo.tickets.tickets,
      seatingId: apiInfo.seats.seatingId,
      address: apiInfo.address,
      payment: apiInfo.payment,
      couponCode: apiInfo.tickets.couponCode
    };
    var info = {
      order: orderInfo,
      type: this.delegate.type,
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
      
    } else {
      var orderInfo = res.order;
      var detailsPath = this.delegate.stepBox.data("order-path").replace(":id", orderInfo.id);
      
      if (this.delegate.admin) {
        window.location = detailsPath;
      
      } else {
        this.box.find(".success").show();
        if (this.delegate.retail) {
          var infoBox = this.box.find(".info");
          infoBox.find(".total span").text(this.formatCurrency(orderInfo.total));
          infoBox.find(".number").text(orderInfo.tickets.length);
          infoBox.find("a.details").prop("href", detailsPath);
          
          var printer = new TicketPrinter();
          setTimeout(function () {
            printer.printTicketsWithNotification(orderInfo.printable_path);
          }, 2000);
          
        } else if (this.delegate.web) {
          this.trackPiwikGoal(1, orderInfo.total);
        }
    
        this.delegate.noFurtherErrors = true;
        this.delegate.killExpirationTimer();
      }
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

function Ordering() {
  this.stepBox;
  this.currentStepIndex = -1;
  this.currentStep;
  this.steps = [];
  this.expirationBox;
  this.expirationTimer = { type: 0, timer: null, times: [420, 60] };
  this.btns;
  this.progressBox;
  this.modalBox;
  this.modalSpinner;
  this.noFurtherErrors = false;
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
    if (!this.currentStep) return;
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
      var scrollPos = this.stepBox;
      if (this.currentStep.validate()) {
        this.showNext(true);
      } else {
        var error = this.stepBox.find(".error:first-child");
        if (error.length) {
          scrollPos = error;
        }
      }
      $("body").animate({ scrollTop: scrollPos.position().top });
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
  
  this.toggleModalBox = function (toggle, callback, stop, instant) {
    if (stop) this.modalBox.stop();
    if (instant) {
      this.modalBox.show();
      if (callback) callback();
      return this.modalBox;
    }
    return this.modalBox["fade" + (toggle ? "In" : "Out")](callback);
  };
  
  this.toggleModalSpinner = function (toggle, instant) {
    if (toggle) {
      this.toggleNextBtn(false);
      this.toggleBtn("prev", false);
      this.toggleModalBox(true, null, true, instant).append(this.modalSpinner.spin().el);
    } else {
      this.updateBtns();
      this.toggleModalBox(false, function () {
        _this.modalSpinner.stop();
      }, true);
    }
  };
  
  this.showModalAlert = function (msg) {
    if (this.noFurtherErrors) return;
    this.noFurtherErrors = true;
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

    this.progressBox.find(".current").removeClass("current");
    this.progressBox.find(".step." + this.currentStep.name).addClass("current");
    var bar = this.progressBox.find(".bar");
    bar.css("left", bar.width() * this.currentStepIndex);
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
    if (this.noFurtherErrors) return;
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
  
  
  _this.stepBox = $(".stepBox");
  if (!_this.stepBox) return;
  _this.expirationBox = $(".expiration");
  _this.btns = $(".btns .btn");
  _this.progressBox = $(".progress");
  _this.modalBox = _this.stepBox.find(".modalAlert");
  
  _this.retailId = _this.stepBox.data("retail-id");
  _this.type = _this.stepBox.data("type");
  _this.retail = _this.type == "retail";
  _this.admin = _this.type == "admin";
  _this.web = !_this.retail && !_this.admin;
  
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
  
  var steps;
  if (_this.retail) {
    steps = [TicketsStep, SeatsStep, ConfirmStep, FinishStep];
  } else {
    steps = [TicketsStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep, FinishStep];
  }
  
  $(window).load(function () {
    var progressSteps = _this.progressBox.find(".step");
    var width = _this.progressBox.width() / (steps.length - 1);
    progressSteps.css({ width: width }).filter(".bar").css({ width: Math.round(width) });
    
    $.each(steps, function (index, stepClass) {
      stepClass.prototype = Step.prototype;
      var step = new stepClass(_this);
      _this.steps.push(step);
    
      progressSteps.filter("." + step.name).show();
    });
    
    _this.registerEvents();
    _this.showNext(false);
    _this.resetExpirationTimer();
  });
}

$(function () {
  if ($(".stepBox").length) {
    new Ordering();
  } else {  
    $("#cancelAction").click(function (event) {
      $(this).hide().siblings("#cancelForm").show();
      event.preventDefault();
    });

    var edit_tickets_form = $("form.edit_tickets");
    var select = edit_tickets_form.submit(function () {
      var $this = $(this);
      var current = $this.find(":selected");
      var method = current.data("method");
      $this.data("confirm", current.data("confirm")).prop("action", current.data("path")).find("input[name=_method]").val(method);
      $this.prop("method", (method == "get") ? method : "post");
    })
    .find("select").change(function () {
      var $this = $(this);
      $this.siblings(".reason").toggle($this.val() == "cancel");
    });
    
    var printer = new TicketPrinter();
    $("a.print-tickets").click(function (event) {
      event.preventDefault();
      printer.printTicketsWithNotification($(this).data("printable-path"));
    });
    
    var seatingBox = $(".seating");
    $.getJSON(seatingBox.data("additional-path"), function (data) {
      var seating = new Seating(seatingBox);
      seating.initSeats(function (seat) {
        var status = data.seats.indexOf(seat.id) != -1 ? Seat.Status.Chosen : Seat.Status.Taken;
        seat.toggleNumber(true);
        seat.setStatus(status);
      });
    });
  }
});
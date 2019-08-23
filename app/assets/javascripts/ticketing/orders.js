//= require ./_seating
//= require ./base
//= require validator-js/validator
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
      var country = parts[1];
      var check = parts[2];
      var bban = parts[3];
      var number = bban + country + check;

      number = number.replace(/\D/g, function (char) {
        return char.charCodeAt(0) - 64 + 9;
      });

      var remainder = 0;
      for (var i = 0; i < number.length; i++) {
        remainder = (remainder + number.charAt(i)) % 97;
      }

      if (country == "DE" && bban.length != 18 ||
          remainder != 1) {
        ok = false;
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
      this.box.animate(props, this.didMoveIn.bind(this));
    } else {
      this.box.css(props);
      this.didMoveIn();
    }
    this.resizeDelegateBox(animate);
  },

  moveOut: function (left) {
    this.box.animate({left: 100 * ((left) ? -1 : 1) + "%"}, function () {
      $(this).hide();
    });
  },

  resizeDelegateBox: function (animated) {
    if (this.box.is(':visible')) {
      this.delegate.resizeStepBox(this.box.outerHeight(true), animated);
    }
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

  validateAsync: function (callback) {
    callback();
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
    var input = this.getFieldWithKey(key);
    var field = input.parents("tr").addClass("error");
    if (msg) field.find(".msg").html(msg);
    this.foundErrors = true;

    this.addBreadcrumb('form error', {
      field: key,
      value: input.val(),
      message: msg
    }, 'warn');
  },

  willMoveIn: function () {},

  didMoveIn: function () {},

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

  addBreadcrumb: function (message, data, level) {
    Raven.captureBreadcrumb({
      category: 'ordering.' + this.name,
      message: message,
      data: data,
      level: level
    });
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

  this.info.api = {
    couponCodes: [],
    tickets: {}
  };
  this.info.internal = {
    ticketTotals: {},
    coupons: [],
    exclusiveSeats: false
  };

  this.getTypeTotal = function ($typeBox, number) {
    return $typeBox.data("price") * $typeBox.find("select").val();
  };

  this.updateSubtotal = function () {
    this.info.internal.subtotal = 0;
    this.info.internal.numberOfTickets = 0;
    this.tickets = [];
    this.box.find(".number tr").each(function () {
      var $this = $(this);
      if ($this.is(".date_ticketing_ticket_type")) {
        var number = parseInt($this.find("select").val());
        _this.info.internal.numberOfTickets += number;
        _this.info.internal.subtotal += _this.getTypeTotal($this);
        for (var i = 0; i < number; i++) {
          _this.tickets.push($this.data("price"));
        }
      } else if ($this.is('.subtotal')) {
        togglePluralText($this.find("td").first(), _this.info.internal.numberOfTickets);
        $this.find(".total span").html(_this.formatCurrency(_this.info.internal.subtotal));
      }
    });

    this.updateDiscounts();
    this.delegate.updateNextBtn();
  };

  this.choseNumber = function ($this) {
    var typeBox = $this.parents("tr"), typeId = typeBox.data("id");
    var total = this.formatCurrency(this.getTypeTotal(typeBox));
    typeBox.find("td.total span").html(total);

    this.info.api.tickets[typeId] = parseInt($this.val());
    this.info.internal.ticketTotals[typeId] = total;
    this.updateSubtotal();

    this.addBreadcrumb('set ticket number', {
      tickets: this.info.api.tickets
    });
  };

  this.addCoupon = function () {
    var code = this.couponBox.find("input[name=code]").val();
    if (this.info.api.couponCodes.indexOf(code) > -1) {
      this.couponAdded({ ok: false, error: "added" });

    } else if (code != "") {
      this.delegate.toggleModalSpinner(true);
      $.post(this.couponBox.data("add-url"), {
        code: code,
        socketId: this.delegate.getStepInfo("seats").api.socketId
      }).always(function (res) { _this.couponAdded(res); });
    }
  };

  this.removeCoupon = function (index) {
    var code = this.info.api.couponCodes[index];

    this.delegate.toggleModalSpinner(true);
    $.post(this.couponBox.data("remove-url"), {
      code: code,
      socketId: this.delegate.getStepInfo("seats").api.socketId
    }).always(function (res) {
      if (res.ok) {
        _this.info.internal.coupons.splice(index, 1);
        _this.info.api.couponCodes.splice(index, 1);
        _this.updateAddedCoupons();
        _this.updateCouponResult('', false);
      }
      _this.delegate.toggleModalSpinner(false);
    });
  };

  this.couponAdded = function (res) {
    var msg = "Ihr Gutschein wurde erfolgreich hinzugefügt. Weitere Gutscheine sind möglich.";
    if (res.ok === false) {
      if (res.error == "expired") {
        msg = "Dieser Code ist leider abgelaufen.";
      } else if (res.error == "added") {
        msg = "Dieser Code wurde bereits zu Ihrer Bestellung hinzugefügt."
      } else {
        msg = "Dieser Code ist nicht gültig.";
      }
    } else if (!res.ok) {
       msg = "Es ist ein unbekannter Fehler aufgetreten.";
    } else {
      var coupon = res.coupon;

      this.info.internal.coupons.push(coupon);
      this.info.api.couponCodes.push(this.couponField.val());

      this.updateAddedCoupons();
      this.trackPiwikGoal(2);

      if (coupon.seats) {
        msg += " Es wurden exklusive Sitzplätze für Sie freigeschaltet.";
      }
    }

    this.couponField.blur().val("");
    this.delegate.toggleModalSpinner(false);
    this.updateCouponResult(msg, !res.ok);
    this.resizeDelegateBox();

    this.addBreadcrumb('entered coupon code', {
      code: res.coupon,
      success: res.ok ? 'true' : 'false',
      error: res.error
    });
  };

  this.updateCouponResult = function (msg, error) {
    this.couponBox.find(".msg .result").text(msg).toggleClass("error", error).parent().toggle(!!msg);
  };

  this.updateAddedCoupons = function () {
    this.info.internal.exclusiveSeats = false;

    var addedBox = this.couponBox.find(".added")
                    .toggle(this.info.api.couponCodes.length > 0)
                    .find("td:last-child")
                    .empty();

    $.each(this.info.internal.coupons, function (i, coupon) {
      _this.info.internal.exclusiveSeats = _this.info.internal.exclusiveSeats || coupon.seats;

      addedBox.append("<b>" + _this.info.api.couponCodes[i] + "</b> (<a href='#' data-index='" + i + "'>entfernen</a>)");
      if (i < _this.info.internal.coupons.length - 1) {
        addedBox.append(", ");
      }
    });

    this.updateDiscounts();
  };

  this.updateDiscounts = function () {
    var tickets = this.tickets.slice(0).sort(function (a, b) {
      return a - b;
    });
    var any_free_tickets = false;
    this.info.internal.total = this.info.internal.subtotal;
    this.info.internal.discount = 0;

    this.box.find("tr.discount").remove();
    $.each(this.info.internal.coupons, function (i, coupon) {
      if (coupon.free_tickets > 0) {
        any_free_tickets = true;
        var discount = 0;

        for (var j = 0; j < coupon.free_tickets; j++) {
          var ticketToRemove = tickets.pop();
          if (ticketToRemove) {
            discount -= ticketToRemove;
          }
        }

        if (!_this.info.api.ignore_free_tickets) {
          _this.info.internal.total += discount;
          _this.info.internal.discount += discount;
        }

        var discountBox = $("<tr>").addClass("discount");
        discountBox.toggleClass("ignore", _this.info.api.ignore_free_tickets);
        var info = $("<td>").addClass("plural_text").attr("colspan", 3).html("Gutschein <em>" + _this.info.api.couponCodes[i] + '</em> (Wert: <span class="number"><span></span></span> Freikarte<span class="plural">n</span>)');
        discountBox.append(
          info,
          $("<td>").addClass("amount").text(_this.formatCurrency(discount) + " €")
        );
        discountBox.insertAfter(_this.box.find("tr.subtotal"));
        togglePluralText(info, coupon.free_tickets);
      }
    });

    this.box.find('tr.ignore_free_tickets').toggle(any_free_tickets && this.info.internal.exclusiveSeats);

    var $this = this.box.find(".number tr.total");
    this.info.internal.zeroTotal = this.info.internal.total <= 0;
    $this.find(".total span").html(_this.formatCurrency(_this.info.internal.total));
  };

  this.nextBtnEnabled = function () {
    return this.info.internal.numberOfTickets > 0;
  };

  this.validate = function () {
    if (this.couponField.val() != "") {
      this.addCoupon();
      return false;
    }
    return true;
  };

  this.couponBox = this.box.find(".coupon");
  this.couponField = this.couponBox.find("input[name=code]");
  this.registerEventAndInitiate(this.box.find("select"), "change", function ($this) {
    _this.choseNumber($this);
  });
  this.couponField.keyup(function (event) {
    if (event.which == 13) _this.addCoupon();
  });
  this.couponBox.find("input[type=submit]").click(function () {
    _this.addCoupon();
  });
  this.couponBox.find(".added").on("click", "a", function (event) {
    _this.removeCoupon($(this).data("index"));
    event.preventDefault();
  });
  this.registerEventAndInitiate(this.box.find("tr.ignore_free_tickets input"), "change", function ($this) {
    _this.info.api.ignore_free_tickets = $this.is(":checked");
    _this.updateDiscounts();
  });
  this.box.find('.event-header').load(function () {
    _this.resizeDelegateBox(true);
  });
}

function SeatsStep(delegate) {
  this.chooser = null;
  var _this = this;

  this.validate = function () {
    return !this.boundToSeats || this.chooser.validate();
  };

  this.nextBtnEnabled = function () {
    return !!this.info.api.date;
  };

  this.willMoveIn = function () {
    if (!this.boundToSeats) return;

    var info = this.delegate.getStepInfo("tickets");
    if (this.numberOfSeats != info.internal.numberOfTickets) {
      this.numberOfSeats = info.internal.numberOfTickets;
      togglePluralText(this.box.find(".note.number_of_tickets"), this.numberOfSeats);
      this.chooser.toggleErrorBox(false);
      this.updateSeatingPlan();
    }
    this.toggleExclusiveSeatsKey(info.internal.exclusiveSeats);
  };

  this.didMoveIn = function () {
    if (this.skipDateSelection) {
      this.choseDate(this.dates.first());
    }
  };

  this.choseDate = function ($this) {
    if ($this.is(".selected") || $this.is(".disabled")) return;
    $this.parents("table").find(".selected").removeClass("selected");
    $this.addClass("selected");

    this.info.api.date = $this.data("id");
    this.info.internal.boxOfficePayment = $this.data("box-office-payment");
    this.info.internal.localizedDate = $this.text();

    if (this.boundToSeats) {
      this.slideToggle(this.seatingBox, true);
      this.updateSeatingPlan();

      $('html, body').animate({ scrollTop: this.seatingBox.offset().top }, 500);

    } else {
      this.delegate.updateNextBtn();
    }

    this.addBreadcrumb('set date', {
      date: this.info.api.date
    });
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
      socketId: this.delegate.getStepInfo("seats").api.socketId
    }).always(function (res) {
      _this.delegate.toggleModalSpinner(false);
      _this.toggleExclusiveSeatsKey(res.seats);
      _this.resizeDelegateBox();
    });
  };

  this.toggleExclusiveSeatsKey = function (toggle) {
    this.chooser.toggleExclusiveSeatsKey(toggle);
  };

  this.expire = function () {
    this.delegate.expire();
    this.addBreadcrumb('session expired');
  };

  this.seatChooserIsReady = function () {
    this.info.api.socketId = this.chooser.socketId;
    this.delegate.toggleModalSpinner(false);
  };

  this.seatChooserIsReconnecting = function () {
    this.delegate.toggleModalSpinner(true, true);
  };

  this.seatChooserDisconnected = function () {
    this.delegate.showModalAlert("Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.");
  };

  this.seatChooserCouldNotConnect = function () {
    this.delegate.showModalAlert("Derzeit ist keine Buchung möglich.<br />Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.");
  };

  this.seatChooserCouldNotReconnect = function () {
    this.expire();
  };

  this.seatChooserExpired = function () {
    this.expire();
  };

  Step.call(this, "seats", delegate);


  this.boundToSeats = this.box.data("boundToSeats");
  this.seatingBox = this.box.find(".seat_chooser");
  if (this.boundToSeats) {
    this.delegate.toggleModalSpinner(true, true);
    this.box.show();
    this.chooser = new SeatChooser(this.seatingBox.find(".seating"), this);
    this.box.hide();
  }
  this.seatingBox.hide();

  this.dates = this.box.find(".date td").click(function () {
    _this.choseDate($(this));
  });
  this.skipDateSelection = this.dates.length < 2 && this.boundToSeats;
  this.box.find(".note").first().toggle(!this.skipDateSelection);

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

  this.willMoveIn = function () {
    if (this.delegate.web) {
      var boxOffice = this.delegate.getStepInfo("seats").internal.boxOfficePayment;
      this.box.find(".transfer").toggle(!boxOffice);
      this.box.find(".box_office").toggle(boxOffice);

      if (!boxOffice && this.info.api.method == "box_office") {
        this.info.api.method = null;
      }
    }
  };

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
    return this.delegate.getStepInfo("tickets").internal.zeroTotal;
  };

  Step.call(this, "payment", delegate);

  this.updateMethods = function () {
    if (this.methodIsCharge()) {
      setTimeout(function () {
        _this.getFieldWithKey('name').focus();
      }, 750);
    }
  };

  this.registerEventAndInitiate(this.box.find("[name=method]"), "click", function ($this) {
    if (!$this.is(":checked")) return;
    _this.info.api.method = $this.val();
    _this.slideToggle(_this.box.find(".charge_data"), _this.methodIsCharge());
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
    var btnText;
    if (this.delegate.web && !this.delegate.getStepInfo("tickets").internal.zeroTotal) {
      btnText = "kostenpflichtig bestellen";
    } else {
      btnText = "bestätigen";
    }
    this.delegate.setNextBtnText(btnText);

    var ticketsInfo = this.delegate.getStepInfo("tickets");
    this.box.find(".date").text(this.delegate.getStepInfo("seats").internal.localizedDate);

    this.box.find(".tickets tbody tr").show().each(function () {
      var typeBox = $(this);
      var number, total;
      if (typeBox.is(".subtotal")) {
        number = ticketsInfo.internal.numberOfTickets;
        total = _this.formatCurrency(ticketsInfo.internal.subtotal);
      } else if (typeBox.is(".discount")) {
        if (ticketsInfo.internal.discount === 0) {
          typeBox.hide();
          return;
        }
        total = _this.formatCurrency(ticketsInfo.internal.discount);
      } else if (typeBox.is(".total")) {
        total = _this.formatCurrency(ticketsInfo.internal.total);
      } else {
        var typeId = typeBox.find("td").first().data("id");
        number = ticketsInfo.api.tickets[typeId];
        if (!number || number < 1) {
          typeBox.hide();
          return;
        }
        total = ticketsInfo.internal.ticketTotals[typeId];
      }
      typeBox.find(".total span").text(total);
      var single = typeBox.find(".single");
      if (typeBox.is(".subtotal")) {
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
      if (this == "payment" && !ticketsInfo.internal.zeroTotal) {
        box.removeClass("transfer charge box_office").addClass(info.api.method);
      }
      $.each(info.api, function (key, value) {
        box.find("."+key).text(value);
      });
    });
  };

  this.validate = function () {
    return this.validateFields(function () {}, function () {
      this.info.api.newsletter = this.info.api.newsletter == "1";
    });
  };

  this.validateAsync = function (callback) {
    this.delegate.toggleModalSpinner(true);
    this.placeOrder(callback);
  };

  this.placeOrder = function (successCallback) {
    this.delegate.hideOrderControls();

    var apiInfo = this.delegate.getApiInfo();

    var orderInfo = {
      date: apiInfo.seats.date,
      tickets: apiInfo.tickets.tickets,
      ignore_free_tickets: apiInfo.tickets.ignore_free_tickets,
      address: apiInfo.address,
      payment: apiInfo.payment,
      coupon_codes: apiInfo.tickets.couponCodes
    };

    var info = {
      order: orderInfo,
      type: this.delegate.type,
      socket_id: apiInfo.seats.socketId,
      newsletter: apiInfo.confirm.newsletter
    };

    $.ajax({
      url: "/api/ticketing/orders",
      type: "POST",
      data: JSON.stringify(info),
      contentType: "application/json",
      success: function (response) {
        _this.orderPlaced(response, successCallback);
      },
      error: this.orderFailed.bind(this)
    });
  };

  this.disconnect = function () {
    var chooser = this.delegate.getStep("seats").chooser;
    if (chooser) chooser.disconnect();
    this.delegate.killExpirationTimer();
  };

  this.orderFailed = function () {
    this.disconnect();
    this.delegate.showModalAlert("Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.");
  };

  this.orderPlaced = function (response, callback) {
    this.disconnect();
    this.delegate.toggleModalSpinner(false);

    this.info.internal.order = response;
    this.info.internal.detailsPath = this.delegate.stepBox.data("order-path").replace(":id", this.info.internal.order.id);

    if (this.delegate.admin) {
      window.location = this.info.internal.detailsPath;
      return;
    }

    callback();
  };
}

function FinishStep(delegate) {
  var _this = this;

  this.willMoveIn = function () {
    var payInfo = this.delegate.getStepInfo("payment");
    if (payInfo) {
      var immediateTickets = ["charge", "credit_card"].indexOf(payInfo.api.method) > -1;
      this.box.find(".tickets").toggle(immediateTickets);
    }

    var confirmInfo = this.delegate.getStepInfo("confirm");
    var orderInfo = confirmInfo.internal.order;
    orderInfo.total = Number.parseFloat(orderInfo.total);

    if (this.delegate.retail) {
      var infoBox = this.box.find(".info");
      infoBox.find(".total span").text(this.formatCurrency(orderInfo.total));
      infoBox.find(".number").text(orderInfo.tickets.length);
      infoBox.find("a.details").prop("href", confirmInfo.internal.detailsPath);

      var printer = new TicketPrinter();
      setTimeout(function () {
        printer.printTicketsWithNotification(orderInfo.printable_path);
      }, 2000);

    } else {
      var email = this.delegate.getApiInfo().address.email;
      var isGmail = /@(gmail|googlemail)\./.test(email);
      this.box.find(".gmail-warning").toggle(isGmail);

      this.box.find('.order-number b').text(orderInfo.number);
      this.trackPiwikGoal(1, orderInfo.total);
    }
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
    $(".progress, .btns").addClass('disabled');
  };

  this.goNext = function ($this) {
    if ($this.is(".disabled")) return;

    if ($this.is(".prev")) {
      this.showPrev();

    } else {
      var scrollPos = this.stepBox;
      if (this.currentStep.validate()) {
        this.currentStep.validateAsync(function () {
          _this.showNext(true);
        });
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

  this.toggleModalBox = function (toggle, stop, instant) {
    if (stop) this.modalBox.stop();
    if (instant) {
      this.modalBox.show();
      return this.modalBox;
    }
    return this.modalBox["fade" + (toggle ? "In" : "Out")]();
  };

  this.toggleModalSpinner = function (toggle, instant) {
    if (toggle) {
      this.toggleNextBtn(false);
      this.toggleBtn("prev", false);
    } else {
      this.updateBtns();
    }
    this.toggleModalBox(toggle, true, instant);
  };

  this.showModalAlert = function (msg) {
    if (this.noFurtherErrors) return;
    this.noFurtherErrors = true;
    this.modalBox.find('.spinner').hide();
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

  this.getStep = function (stepName) {
    var step;
    this.steps.forEach(function (s) {
      if (s.name == stepName) {
        step = s;
        return;
      }
    });
    return step;
  };

  this.getStepInfo = function (stepName) {
    var step = this.getStep(stepName);
    if (step) {
      return step.info;
    }
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

  _this.type = _this.stepBox.data("type");
  _this.retail = _this.type == "retail";
  _this.admin = _this.type == "admin";
  _this.web = !_this.retail && !_this.admin;

  var steps;
  if (_this.retail) {
    steps = [TicketsStep, SeatsStep, ConfirmStep, FinishStep];
  } else {
    steps = [TicketsStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep, FinishStep];
  }

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
      $this.siblings(".cancellation").toggle($this.val() == "cancel");
    });

    var toggleAmount = function () {
      $(this).siblings("span").toggle($(this).val() == "correction");
    };
    var billingNote = $(".billingLog select").change(toggleAmount);
    toggleAmount.call(billingNote);

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
        seat.setStatus(status);
      });
    });
  }
});

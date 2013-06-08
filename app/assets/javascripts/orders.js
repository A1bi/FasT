//= require _seats

function Step(name, delegate) {
	this.name = name;
	this.box = $(".stepCon." + this.name);
	this.info = {};
	this.delegate = delegate;
	
	this.registerEvents();
}

Step.prototype = {
	moveIn: function (animate) {
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
        _this.info[this.name.replace(pattern, "$1")] = this.value;
      }
		});
  },
	
	updateOrder: function (callback) {
		this.delegate.updateOrder(this, callback);
	},
	
	validate: function () {
		var _this = this;
    this.toggleFormFields(false);
		this.updateOrder(function (response) {
			_this.afterValidate(response);
			_this.delegate.validatedStep(response.ok);
		});
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
  
  this.info.tickets = {};

	this.formatCurrency = function (value) {
		return value.toFixed(2).toString().replace(".", ",");
	};
	
	this.getTypeTotal = function ($typeBox) {
		return $typeBox.data("price") * $typeBox.find("select").val();
	};
	
	this.updateTotal = function () {
		var total = 0;
    this.info.numberOfTickets = 0;
		this.box.find(".number tr").each(function () {
			if ($(this).is(".ticketing_ticket_type")) {
        var $this = $(this);
        _this.info.numberOfTickets += parseInt($this.find("select").val());
				total += _this.getTypeTotal($this);
			} else {
				$(this).find(".total span").html(_this.formatCurrency(total));
			}
		});
		
		this.delegate.toggleNextBtn(this.info.numberOfTickets > 0);
	};
	
	this.choseDate = function ($this) {
		$this.parent().find(".selected").removeClass("selected");
		$this.addClass("selected");
		this.slideToggle(this.box.find("div.number"), true);
		
		this.info.date = $this.data("id");
    this.info.localizedDate = $this.text();
		this.updateOrder();
	};
	
	this.choseNumber = function ($this) {
		var typeBox = $this.parents("tr");
		typeBox.find("td.total span").html(this.formatCurrency(this.getTypeTotal(typeBox)));
		this.updateTotal();
		
		this.info.tickets[typeBox.data("id")] = parseInt($this.val());
		this.updateOrder();
	};
}

function SeatsStep(delegate) {
	this.updateTimer = null;
  this.seats = {};
  this.date = 0;
  this.seating = null;
  this.seatsToSelect = 0;
	var _this = this;
  
  this.updateSeats = function (seats) {
    $.extend(true, this.seats, seats);
    this.updateSeatPlan();
  };
  
  this.updateSeatPlan = function () {
    if (!this.date) return;
    $.each(this.seats[this.date], function (seatId, seatInfo) {
      _this.box.find("#ticketing_seat_" + seatId)
        .toggleClass("selected", seatInfo.selected === true)
        .toggleClass("taken", seatInfo.reserved);
    });
    
    this.updateAvailableSeats();
  };
  
  this.updateAvailableSeats = function () {
    this.seating.seats.each(function () {
      $(this).toggleClass("available", $(this).is(":not(.taken):not(.selected)"));
    });
  };
  
  this.reserveSeat = function ($seat) {
    if (!$seat.is(".available")) return;
    this.delegate.killExpirationTimer();
    
    $seat.addClass("selected");
    this.updateAvailableSeats();
    
    this.delegate.node.emit("reserveSeat", { seatId: $seat.data("id") }, function (res) {
      if (!res.ok) $seat.removeClass("selected").addClass("taken");
      if (_this.box.find(".error").is(":visible")) _this.updateSeatsToSelectMessage();
    });
  };
  
  this.validate = function () {
    this.updateSeatsToSelectMessage();
    
    Step.prototype.validate.call(this);
  };
  
  this.updateSeatsToSelectMessage = function () {
    var diff = this.seatsToSelect - this.seating.seats.filter(".selected").length;
    var errorBox = this.box.find(".error");
    if (diff > 0) {
      errorBox.find(".number").text(diff);
      this.toggleMessageCssClass(errorBox, diff, "error");
    }
    this.slideToggle(errorBox, diff > 0);
  };
  
  this.toggleMessageCssClass = function (box, number, preservedClass) {
    var cssClass = (number != 1) ? "plural" : "singular";
    box.removeClass().addClass(preservedClass + " message " + cssClass);
  };
	
	this.registerEvents = function () {
    this.box.show();
    this.seating = new Seating(this.box.find(".seating"));
    this.box.hide();
    
    this.seating.seats.click(function () {
      _this.reserveSeat($(this));
		});
    
    this.delegate.node.on("updateSeats", function (res) {
      _this.updateSeats(res.seats);
    });
    
    this.delegate.observeOrder("date", function (info) {
      if (_this.date != info.date) {
        _this.date = info.date;
        _this.updateSeatPlan();
      }
      
      _this.seatsToSelect = info.numberOfTickets;
      _this.box.find(".number span").text(_this.seatsToSelect);
      _this.toggleMessageCssClass(_this.box.find(".note"), _this.seatsToSelect, "note");
      _this.box.find(".error").hide();
    });
	};
	
	Step.call(this, "seats", delegate);
  
  this.updateAvailableSeats();
}

function AddressStep(delegate) {
	var _this = this;
	
	this.validate = function () {
    this.updateInfo();
		Step.prototype.validate.call(this);
	};
  
  this.moveIn = function () {
    this.delegate.toggleNextBtn(true);
    Step.prototype.moveIn.call(this);
  };
  
  Step.call(this, "address", delegate);
}

function PaymentStep(delegate) {
	var _this = this;
  
  this.registerEvents = function () {
    this.box.find("[name=method]").click(function () {
      _this.info.method = $(this).val();
      _this.slideToggle(_this.box.find(".charge"), _this.info.method == "charge");
      _this.delegate.toggleNextBtn(true);
    });
  };
  
	this.validate = function () {
    this.updateInfo();
		Step.prototype.validate.call(this);
	};
	
	Step.call(this, "payment", delegate);
  
  this.moveIn = function () {
    this.delegate.toggleNextBtn(this.info.method);
    Step.prototype.moveIn.call(this);
  };
}

function ConfirmStep(delegate) {
	var _this = this;
  
  this.registerEvents = function () {
    this.box.find(".accept :checkbox").click(function () {
      _this.info.accepted = $(this).is(":checked");
      _this.delegate.toggleNextBtn(_this.info.accepted);
    });
    
    this.delegate.observeOrder("date", function (info) {
      var total = 0;
      $.each(info.tickets, function (typeId, number) {
        var typeBox = _this.box.find("#ticketing_ticket_type_" + typeId);
        typeBox.find(".number").text(number || 0);
        var totalBox = typeBox.find(".total");
        var subtotal = totalBox.data("price") * number;
        totalBox.find("span").text(_this.formatCurrency(subtotal));
        total += subtotal;
      });
      _this.box.find(".total .total span").text(_this.formatCurrency(total));
      _this.box.find(".date").text(info.localizedDate);
    });
    $.each(["address", "payment"], function (i, key) {
      _this.delegate.observeOrder(key, function (info) {
        if (key == "payment") {
          _this.box.find(".payment").removeClass("transfer charge").addClass(info.method);
        }
        _this.updateSummary(info, key);
      });
    });
  };
  
  this.updateSummary = function (info, part) {
    $.each(info, function (key, value) {
      _this.box.find("."+part+" ."+key).text(value);
    });
  };
  
	this.formatCurrency = function (value) {
		return value.toFixed(2).toString().replace(".", ",");
	};
  
  this.moveIn = function () {
    Step.prototype.moveIn.call(this);
    this.delegate.toggleNextBtn(this.info.accepted);
    this.delegate.setNextBtnText("bestellen");
  };
	
	Step.call(this, "confirm", delegate);
}

function FinishStep(delegate) {
  var _this = this;
  
  this.registerEvents = function () {
    this.delegate.observeOrder("payment", function (info) {
      _this.box.find(".tickets").toggle(info.payment == "charge");
    });
  };
  
  this.moveIn = function () {
    this.delegate.hideOrderControls();
    Step.prototype.moveIn.call(this);
  };
  
	Step.call(this, "finish", delegate);
}

var ticketing = new function () {
	this.stepBox = null;
	this.currentStepIndex = -1;
	this.currentStep = null;
	this.order = {};
	this.observers = {};
	this.steps = [];
  this.node = null;
  this.expirationBox = null;
  this.expirationTimer = null;
  this.aborted = false;
	var _this = this;
	
	this.toggleBtn = function (btn, toggle, style_class) {
		style_class = style_class || "disabled";
		$(".btn."+btn).toggleClass(style_class, !toggle);
	};
	
	this.toggleNextBtn = function (toggle) {
		this.toggleBtn("next", toggle);
	};
	
	this.toggleLoadingBtn = function (toggle) {
		this.toggleBtn("next", !toggle, "loading");
		if (this.currentStepIndex > 0) this.toggleBtn("prev", !toggle);
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
			this.toggleLoadingBtn(true);
			this.currentStep.validate();
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
		var progressBox = $(".progress");
		progressBox.find(".current").removeClass("current");
		var current = progressBox.find(".step").eq(this.currentStepIndex+1).addClass("current");
		progressBox.find(".bar").css("left", current.position().left);
	};
	
	this.moveInCurrentStep = function (animate) {
		this.currentStep.moveIn(animate);
		this.toggleBtn("prev", this.currentStepIndex > 0);
		this.updateProgress();
	};
	
	this.validatedStep = function (ok, info) {
		if (ok) {
			this.showNext(true);
		} else {
		  $("body").animate({ scrollTop: this.stepBox.position().top });
		}
		
		this.toggleLoadingBtn(false);
	};
	
	this.resizeStepBox = function (height, animated) {
		var props = { height: height };
		
		if (animated) {
			this.stepBox.animate(props);
		} else {
			this.stepBox.css(props);
		}
	};
	
	this.getObservers = function (prop) {
		var observers = prop && this.observers[prop];
	    if (!observers) {
			observers = this.observers[prop] = $.Callbacks();
		}
		
		return observers;
	};
	
	this.observeOrder = function (prop, callback) {
		this.getObservers(prop).add(callback);
	};
	
	this.notifyObservers = function (prop, value) {
		this.getObservers(prop).fire(value);
	};
	
	this.updateOrder = function (step, callback) {
		this.notifyObservers(step.name, step.info);
		if (callback) {
			var update = {
				order: {
					step: step.name,
					info: step.info
				}
			};
			this.node.emit("updateOrder", update, callback);
      this.killExpirationTimer();
		}
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
    
    this.node.on("orderPlaced", function (response) {
      if (response.ok) {
        _this.aborted = true;
      } else {
        _this.showModalAlert("Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.");
      }
    });
    
    this.node.on("aboutToExpire", function (data) {
      _this.expirationBox.slideDown();
      _this.updateExpirationCounter(data.secondsLeft);
    });
    
    this.node.on("expired", function () {
      _this.expirationBox.slideUp();
      _this.showModalAlert("Ihre Sitzung ist abgelaufen.<br />Wenn Sie möchten, können Sie den Bestellvorgang erneut starten.");
    });
    
    this.node.on("disconnect", function () {
      _this.showModalAlert("Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.");
    });
	};
	
	$(function () {
		_this.stepBox = $(".stepBox");
    _this.expirationBox = $(".expiration");
    
    try {
      _this.node = io.connect("/web", {
        "resource": "node",
        "reconnect": false,
        "sync disconnect on unload": true
      });
      
      _this.registerEvents();
      
  		$.each([DateStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep, FinishStep], function (index, stepClass) {
  			stepClass.prototype = Step.prototype;
  			_this.steps.push(new stepClass(_this));
  		});
		
  		_this.showNext(false);
      
    } catch(err) {
      _this.showModalAlert("Derzeit ist keine Buchung möglich.<br />Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.");
    }
	});
}
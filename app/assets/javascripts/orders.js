//= require _seats

function Step(name, delegate) {
	this.name = name;
	this.box = $(".stepCon." + this.name);
	this.info = {};
	this.delegate = delegate;
	
	this.registerEvents();
}

Step.prototype = {
	moveIn: function () {
		this.box.show().animate({left: "0%"});
		this.resizeDelegateBox(true);
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
    if (!response.ok) {
      this.toggleFormFields(true);
      
      this.box.find("tr").removeClass("error");
  		$.each(response.errors, function (key, error) {
  			_this.box.find("#" + _this.name + "_" + key).parents("tr").addClass("error").find(".msg").html(error);
  		});
    }
	},
  
	registerEvents: function () {}
};

function DateStep(delegate) {
	this.total = 0;
	var _this = this;
	
	this.registerEvents = function () {
		this.box.find("li").click(function (xfg) {
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
		total = 0, _this = this;
		this.box.find(".number tr").each(function () {
			if ($(this).is(".ticketing_ticket_type")) {
				total += _this.getTypeTotal($(this));
			} else {
				$(this).find(".total span").html(_this.formatCurrency(total))
			}
		});
		
		this.delegate.toggleNextBtn(total > 0);
	};
	
	this.choseDate = function ($this) {
		$this.parent().find(".selected").removeClass("selected");
		$this.addClass("selected");
		this.slideToggle(this.box.find("div.number"), true);
		
		this.info.date = $this.data("id");
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
	var _this = this;
  
  this.updateSeats = function (seats) {
    $.extend(true, this.seats, seats);
    this.updateSeatPlan();
  };
  
  this.updateSeatPlan = function () {
    $.each(this.seats[this.date], function (seatId, seatInfo) {
      _this.box.find("#ticketing_seat_" + seatId)
        .toggleClass("selected", seatInfo.selected === true)
        .toggleClass("taken", seatInfo.reserved);
    });
    
    this.updateAvailableSeats();
  };
  
  this.updateAvailableSeats = function () {
    this.box.find(".ticketing_seat").each(function () {
      $(this).toggleClass("available", $(this).is(":not(.taken):not(.selected)"));
    });
  };
  
  this.reserveSeat = function ($seat) {
    if (!$seat.is(".available")) return;
    this.delegate.killExpirationTimer();
    
    $seat.addClass("selected");
    _this.updateAvailableSeats();
    
    _this.delegate.node.emit("reserveSeat", { seatId: $seat.data("id") }, function (res) {
      if (!res.ok) $seat.removeClass("selected").addClass("taken");
    });
  };
	
	this.registerEvents = function () {
    this.box.find(".ticketing_seat").click(function () {
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
    });
    
    this.box.show();
    this.seating = new Seating(this.box.find(".seating"), false);
    this.box.hide();
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
  };
	
	Step.call(this, "confirm", delegate);
}

function FinishStep(delegate) {
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
	
	this.showNext = function () {
		if (this.currentStep) {
			this.currentStep.moveOut(true);
		}
		this.updateCurrentStep(1);
		this.moveInCurrentStep();
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
	
	this.moveInCurrentStep = function () {
		this.currentStep.moveIn();
		this.toggleBtn("prev", this.currentStepIndex > 0);
		this.updateProgress();
	};
	
	this.validatedStep = function (ok, info) {
		if (ok) {
			this.showNext();
		}
		
		this.toggleLoadingBtn(false);
	};
	
	this.resizeStepBox = function (height, animated) {
		var props = {height: height};
		
		if (animated) {
			this.stepBox.animate(props);
		} else {
			$(".stepBox").css(props);
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
    this.stepBox.find(".expiration span").html(seconds);
    this.expirationTimer = setTimeout(function () {
      _this.updateExpirationCounter(--seconds);
    }, 1000);
  };
  
  this.killExpirationTimer = function () {
    _this.stepBox.find(".expiration").slideUp();
    clearTimeout(this.expirationTimer);
  };
	
	this.registerEvents = function () {
		$(".btn").click(function () {
			_this.goNext($(this));
		});
    
    this.node.on("aboutToExpire", function (data) {
      _this.stepBox.find(".expiration").slideDown();
      _this.updateExpirationCounter(data.secondsLeft);
    });
    
    this.node.on("expired", function () {
      _this.stepBox.find(".expiration").slideUp();
      _this.showModalAlert("Ihre Sitzung ist abgelaufen.<br />Wenn Sie möchten, können Sie den Bestellvorgang erneut starten.");
    });
    
    this.node.on("disconnect", function () {
      _this.showModalAlert("Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.");
    });
	};
	
	$(function () {
		_this.stepBox = $(".stepBox");
    
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
		
  		_this.showNext();
      
    } catch(err) {
      _this.showModalAlert("Derzeit ist keine Buchung möglich.<br />Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.");
    }
	});
}
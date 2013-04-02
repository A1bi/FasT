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
	
	updateOrder: function (callback) {
		this.delegate.updateOrder(this, callback);
	},
	
	validate: function () {
		var _this = this;
		this.updateOrder(function (response) {
			_this.afterValidate(response);
			_this.delegate.validatedStep(response.ok);
		});
	},
	
	afterValidate: function () {},
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

	this.formatCurrency = function (value) {
		return value.toFixed(2).toString().replace(".", ",");
	};
	
	this.getTypeTotal = function ($typeBox) {
		return $typeBox.data("price") * $typeBox.find("select").val();
	};
	
	this.updateTotal = function () {
		total = 0, _this = this;
		this.box.find(".number tr").each(function () {
			if ($(this).is(".tickets_ticket_type")) {
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
		
		var numbers = this.info.numbers || {};
		numbers[typeBox.data("id")] = $this.val();
		
		this.info.numbers = numbers;
		this.updateOrder();
	};
}

function SeatsStep(delegate) {
	this.updateTimer = null;
  this.seats = {};
  this.date = 0;
	var _this = this;
  
  this.updateSeats = function (seats) {
    $.extend(true, this.seats, seats);
    this.updateSeatPlan();
  };
  
  this.updateSeatPlan = function () {
    $.each(this.seats[this.date], function (seatId, seatInfo) {
      _this.box.find("#tickets_seat_" + seatId)
        .toggleClass("selected", seatInfo.selected)
        .toggleClass("taken", seatInfo.reserved);
    });
    
    this.updateAvailableSeats();
  };
  
  this.updateAvailableSeats = function () {
    this.box.find(".tickets_seat").each(function () {
      $(this).toggleClass("available", $(this).is(":not(.taken):not(.selected)"));
    });
  };
  
  this.reserveSeat = function ($seat) {
    if (!$seat.is(".available")) return;
    
    $seat.addClass("selected");
    _this.updateAvailableSeats();
    
    _this.delegate.node.emit("reserveSeat", { seatId: $seat.data("id") }, function (res) {
      if (!res.ok) $seat.removeClass("selected").addClass("taken");
    });
  };
	
	this.registerEvents = function () {
    this.box.find(".tickets_seat").click(function () {
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
	};
	
	Step.call(this, "seats", delegate);
  
  this.updateAvailableSeats();
}

function AddressStep(delegate) {
	var _this = this;
	
	this.registerEvents = function () {
		this.box.find(".field").change(function () {
			$.each($(this).parents("form").serializeArray(), function () {
        var pattern = /tickets_order\[([a-z_]+)\]/;
        if (pattern.test(this.name)) {
          _this.info[this.name.replace(pattern, "$1")] = this.value;
        }
			});
		});
	};
	
	Step.call(this, "address", delegate);
	
	this.toggleFormFields = function (toggle) {
		this.box.find("form input").attr("disabled", !toggle);
	};
	
	this.validate = function () {
		this.toggleFormFields(false);
		Step.prototype.validate.call(this);
	};
	
	this.afterValidate = function (response) {
		this.toggleFormFields(true);
    this.box.find("tr").removeClass("error");
		$.each(response.errors, function (key, error) {
			_this.box.find("#tickets_order_" + key).parents("tr").addClass("error").find(".msg").html(error);
		});
	};
}

function PaymentStep(delegate) {
	var _this = this;
	
	Step.call(this, "payment", delegate);
}

function ConfirmStep(delegate) {
	var _this = this;
	
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
		this.toggleBtn("prev", !toggle);
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
		}
	};
	
	this.registerEvents = function () {
		$(".btn").click(function () {
			_this.goNext($(this));
		});
	};
	
	$(function () {
    // TODO: error handling (connection to server refused or lost)
    _this.node = io.connect("", {
      "resource": "node",
      "sync disconnect on unload": true
    });
    
		$.each([DateStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep, FinishStep], function (index, stepClass) {
			stepClass.prototype = Step.prototype;
			_this.steps.push(new stepClass(_this));
		});
		
		_this.stepBox = $(".stepBox");
		_this.registerEvents();
		_this.showNext();
	});
}
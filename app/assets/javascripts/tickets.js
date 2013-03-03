var Step = {
	box: null,
	delegate: null,
	info: null,
	
	init: function (delegate) {
		this.delegate = delegate;
		this.box = $(".stepCon." + this.name);
		this.registerEvents();
		this.info = {};
	},
	
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
	
	handleErrors: function () {},
	
	validate: function () {
		var _this = this;
		this.updateOrder(function (response) {
			_this.delegate.validatedStep(response.ok);
			if (!response.ok) _this.handleErrors(response.errors);
		});
	}
}


var tickets = {
	stepBox: null,
	currentStepIndex: -1,
	currentStep: null,
	order: {},
	observers: {},
	
	steps: [
		$.extend({}, Step, {
			name: "date",
			total: 0,
			
			formatCurrency: function (value) {
				return value.toFixed(2).toString().replace(".", ",");
			},
			
			getTypeTotal: function ($typeBox) {
				return $typeBox.data("price") * $typeBox.find("select").val();
			},
			
			updateTotal: function () {
				total = 0, _this = this;
				this.box.find(".number tr").each(function () {
					if ($(this).is(".tickets_ticket_type")) {
						total += _this.getTypeTotal($(this));
					} else {
						$(this).find(".total span").html(_this.formatCurrency(total))
					}
				});
				
				this.delegate.toggleNextBtn(total > 0);
			},
			
			choseDate: function ($this) {
				$this.parent().find(".selected").removeClass("selected");
				$this.addClass("selected");
				this.slideToggle(this.box.find("div.number"), true);
				
				this.info.date = $this.data("id");
				this.updateOrder();
			},
			
			choseNumber: function ($this) {
				var typeBox = $this.parents("tr");
				typeBox.find("td.total span").html(this.formatCurrency(this.getTypeTotal(typeBox)));
				this.updateTotal();
				
				var numbers = this.info.numbers || {};
				numbers[typeBox.data("id")] = $this.val();
				
				this.info.numbers = numbers;
				this.updateOrder();
			},
			
			registerEvents: function () {
				var _this = this;
				this.box.find("li").click(function () {
					_this.choseDate($(this));
				});
				this.box.find("select").change(function () {
					_this.choseNumber($(this));
				});
			}
		}),
		
		$.extend({}, Step, {
			name: "seats",
			updateTimer: null,
			
			updateSeats: function () {
				var _this = this;
				clearTimeout(this.updateTimer);
				
				$.getJSON("/tickets/seats", function (response) {
					$.each(response.seats, function (index, seat) {
						_this.box.find("#tickets_seat_" + seat.id).toggleClass("taken", !seat.available);
					});
				});
				
				this.updateTimer = setTimeout(this.updateSeats, 5000);
			},
			
			registerEvents: function () {
				var _this = this;
				
				this.box.find(".tickets_seat").click(function () {
					var $seat = $(this).addClass("selected");
					var data = {
						id: $seat.data("id"),
						date: _this.delegate.order.date
					}
					$.post("/tickets/reserve_seat", data, function (response) {
						if (!response.ok) {
							$seat.removeClass("selected");
						}
					}, "json");
				});
				
				this.delegate.observeOrder("date", function (date) {
					if (date['date']) _this.updateSeats();
				});
			}
		}),
		
		$.extend({}, Step, {
			name: "address",
			info: {},
			
			handleErrors: function (errors) {
				var _this = this;

				$.each(errors, function (key, error) {
					_this.box.find("#tickets_order_" + key).val("FAAAAALLLSCH!!");
				});
			},
			
			registerEvents: function () {
				var _this = this;
				
				this.box.find(".field").change(function () {
					$.each($(this).parents("form").serializeArray(), function () {
						_this.info[this.name] = this.value;
					});
					console.log(_this.info);
				});
			}
		})
	],
	
	toggleBtn: function (btn, toggle, style_class) {
		style_class = style_class || "disabled";
		$(".btn."+btn).toggleClass(style_class, !toggle);
	},
	
	toggleNextBtn: function (toggle) {
		this.toggleBtn("next", toggle);
	},
	
	toggleLoadingBtn: function (toggle) {
		this.toggleBtn("next", !toggle, "loading");
		this.toggleBtn("prev", !toggle);
	},
	
	goNext: function ($this) {
		if ($this.is(".disabled")) return;
		
		if ($this.is(".prev")) {
			this.showPrev();
			
		} else {
			this.toggleLoadingBtn(true);
			this.currentStep.validate();
		}
	},
	
	showNext: function () {
		if (this.currentStep) {
			this.currentStep.moveOut(true);
		}
		this.updateCurrentStep(1);
		this.moveInCurrentStep();
	},
	
	showPrev: function () {
		this.currentStep.moveOut(false);
		this.updateCurrentStep(-1);
		this.moveInCurrentStep();
	},
	
	updateCurrentStep: function (inc) {
		this.currentStepIndex += inc;
		this.currentStep = this.steps[this.currentStepIndex];
	},
	
	updateProgress: function() {
		var progressBox = $(".progress");
		progressBox.find(".current").removeClass("current");
		var current = progressBox.find(".step").eq(this.currentStepIndex+1).addClass("current");
		progressBox.find(".bar").css("left", current.position().left);
	},
	
	moveInCurrentStep: function () {
		this.currentStep.moveIn();
		this.toggleBtn("prev", this.currentStepIndex > 0);
		this.updateProgress();
	},
	
	validatedStep: function (ok, info) {
		if (ok) {
			this.showNext();
		}
		
		this.toggleLoadingBtn(false);
	},
	
	resizeStepBox: function (height, animated) {
		var props = {height: height};
		
		if (animated) {
			this.stepBox.animate(props);
		} else {
			$(".stepBox").css(props);
		}
	},
	
	getObservers: function (prop) {
		var observers = prop && this.observers[prop];
	    if (!observers) {
			observers = this.observers[prop] = $.Callbacks();
		}
		
		return observers;
	},
	
	observeOrder: function (prop, callback) {
		this.getObservers(prop).add(callback);
	},
	
	notifyObservers: function (prop, value) {
		this.getObservers(prop).fire(value);
	},
	
	updateOrder: function (step, callback) {
		this.notifyObservers(step.name, step.info);
		if (callback) {
			var update = {
				order: {
					step: step.name,
					info: step.info
				}
			};
			$.post("/tickets/update_order", update, callback, "json");
		}
	},
	
	registerEvents: function () {
		var _this = this;
		$(".btn").click(function () {
			_this.goNext($(this));
		});
	},
	
	init: function () {
		this.stepBox = $(".stepBox");

		var _this = this;
		$.each(this.steps, function (index, step) {
			step.init(_this);
		});
		
		this.registerEvents();
		this.showNext();
	}
}

$(function () {
	tickets.init();
});
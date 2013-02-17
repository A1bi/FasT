var Step = {
	box: null,
	delegate: null,
	
	init: function (delegate) {
		this.delegate = delegate;
		this.box = $(".stepCon." + this.name);
		this.registerEvents();
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
	}
}


var tickets = {
	stepBox: null,
	currentStepIndex: -1,
	currentStep: null,
	
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
				
				this.delegate.toggleNextBtn(this.isValid());
			},
			
			choseDate: function ($this) {
				$this.parent().find(".selected").removeClass("selected");
				$this.addClass("selected");
				
				this.slideToggle(this.box.find("div.number"), true);
			},
			
			choseNumber: function ($this) {
				var typeBox = $this.parents("tr");
				typeBox.find("td.total span").html(this.formatCurrency(this.getTypeTotal(typeBox)));
				this.updateTotal();
			},
			
			validate: function () {
				this.delegate.validatedStep(this.isValid());
			},
			
			isValid: function () {
				return total > 0;
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
			
			validate: function () {
				
			},
			
			registerEvents: function () {
				var _this = this;
				
			}
		}),
		
		$.extend({}, Step, {
			name: "address",
			
			validate: function () {
				
			},
			
			registerEvents: function () {
				var _this = this;
				
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
		this.currentStepIndex = 0;
		this.showNext();
	}
}

$(function () {
	tickets.init();
});
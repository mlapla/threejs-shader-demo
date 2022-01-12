class GradientLargeStep {
	constructor(f) {
		this.descentStepFactor = 1.0;
		this.f = f
		this.derivativeStepSize = 0.05
	}

	dfdx(x,y) {
		return ( this.f(x + this.h,y) - this.f(x,y) ) / h; 
	}

	dfdy(x,y) {
		return ( this.f(x,y + this.h) - this.f(x,y) ) / h; 
	}

}
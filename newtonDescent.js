class NewtonDescent {
	constructor(f) {
		this.f = f;
		this.h = 0.001;
		this.stepLimit = 20;
		this.errorTolerance = 0.001;
	}

	dfdx(x) {
		return ( this.f(x + this.h) - this.f(x) ) / this.h; 
	}

	findZero(seed){
		let x = seed;
		let error = this.f(x);
		console.log("Find zero:")

		for (let i = 0; i < this.stepLimit && Math.abs(error) > this.errorTolerance; i++) {
			let f1 = error;
			let f2 = this.f(x + this.h);
			let df = (f2 - f1) / this.h;

			x = x - f1/df;
			error = this.f(x);
			console.log([i,f1,f2,df,x,error]);
		}

		return x;

	}

	

}

if (require.main === module) {
    let newton = new NewtonDescent(function(x){
    	return (x-2)*(x+1);
    });
    let r = Math.random();
    console.log(newton.findZero(r));
}
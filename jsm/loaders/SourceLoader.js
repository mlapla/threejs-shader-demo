/**
 * @author jaliborc / http://jaliborc.com/
 */
import * as THREE from '../../build/three.module.js'

class SourceLoader extends Loader {

	constructor( manager ) {

		super( manager );

		this.materials = null;

	}

	function load(urls, onLoad) {
		this.urls = urls
		this.results = {}
		this.loadFile(0)
		this.onLoad = onLoad
	},

	loadFile: function(i) {
		if (i == this.urls.length)
    		return this.onLoad(this.results)

    	var scope = this
    	var url = this.urls[i]
		var loader = new THREE.FileLoader(this.manager);
		loader.setCrossOrigin(this.crossOrigin);
		loader.load(url, function(text) {
			scope.results[url] = text
	    	scope.loadFile(i+1)
	  	})
	}
}

export { SourceLoader };
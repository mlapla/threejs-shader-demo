"use strict";

import * as THREE from './build/three.module.js';
// import * as THREE from 'three';
import Stats from './jsm/libs/stats.module.js';

THREE.Cache.enabled = true;

// Import all algos
// Make a canvas for each algo
// Render each algo

let shaders = [
//   ['./glsl/default.vs.glsl','./glsl/scrollingColor.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/vonoroi.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/fracBrownMotion.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/octograms.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/nova.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/foggyVonoroi.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/newton.fs.glsl'],
//   ['./glsl/default.vs.glsl','./glsl/mandelbrot.fs.glsl'],
  ['./glsl/default.vs.glsl','./glsl/julia.fs.glsl']
];

// const vertexShader = require('raw-loader!./default.vs.glsl');
// const shaderURLs = require.context('./glsl',false,/\.glsl$/);
// console.log(shaderURLs)
// shaderURLs = shaderURLs.keys().map(shaderURLs);
// console.log(shaderURLs)

const nShaders = 1;
const nRows = 1;
const nColumns = 1;
let tileWidth = window.innerWidth / nColumns;
let tileHeight = window.innerHeight / nRows; 

function gridOffset(n){
	// [x,y] with respect to the lower-left of the lower-left corner of the plane.
	const i = n % nColumns;
	const j = Math.floor(n / nColumns);
	return [ i * tileWidth, (nRows - 1 - j) * tileHeight]; 
}

function tileCenter(n){
	// [x,y] with respect to center of image of dim 2 window.width x 2 window.height
	const i = n % nColumns;
	const j = Math.floor(n / nColumns);
	const x = - window.innerWidth  / 2 + tileWidth  / 2 + i  * tileWidth;
	const y =   window.innerHeight / 2 - tileHeight / 2 - j * tileHeight;
	return [x,y];
}

function init(canvas) {

	if (canvas == undefined){
		canvas = document.getElementById("container")
	}

	// Renderer
	const renderer = new THREE.WebGLRenderer( { antialias: true } );
	renderer.setPixelRatio( window.devicePixelRatio );
	renderer.setSize( window.innerWidth, window.innerHeight );
	canvas.appendChild( renderer.domElement );

	// Stats
	const stats = new Stats();
	canvas.appendChild( stats.dom );

	// Scene
	const scene = new THREE.Scene();
	const camera = new THREE.OrthographicCamera( - window.innerWidth / 2,
		window.innerWidth / 2, 
		window.innerHeight / 2, 
		-window.innerHeight / 2, 
		-10, 10 
	);
	scene.add(camera)

	// Grid of shaders
	let materials = createMaterials();
	let meshes = [];
	const loadingManager = new THREE.LoadingManager( function(){
		meshes = createMeshes( materials, nRows, nColumns );
		meshes.forEach( (m) =>{
			scene.add(m);
		});
	});
	loadShadersToMaterials( materials,loadingManager );

	// End init
	window.addEventListener( 'resize', onWindowResize );
	window.addEventListener( 'mousemove', onMouseMove );

	main(scene);

	function main(scene) {

		function animate(time){

			time *= 0.001

			materials.forEach((m) => {
				m.uniforms.iTime.value = time;
			});

			renderer.render(scene, camera);

			requestAnimationFrame(animate);
		    stats.update();
		}
		
		requestAnimationFrame(animate)
	}

	function onMouseMove(){
		materials.forEach( (m) => {
			const mouse = [event.clientX ,	window.innerHeight - event.clientY]
			m.uniforms.iMouse.value.set( mouse[0], mouse[1] );
		});
	}

	function onWindowResize(){
		// Adjust Rendering resolution
		renderer.setSize(window.innerWidth, window.innerHeight);
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();

    	// Adjust grid of shaders resolution
		materials.forEach( (m,i) => {
			let offset = gridOffset(i)
			m.uniforms.iOffset.value.set( offset[0], offset[1] );
			m.uniforms.iResolution.value.set( window.innerWidth, window.innerHeight );
		})
	}

}

function createMaterials(){

	let materials = [];

	for (let i = 0; i < nShaders; i++)
	{
		const offset = gridOffset(i);

		const uniforms = {
			iTime: { value: 0 },
			iOffset: { value: new THREE.Vector2( offset[0], offset[1] ) } ,
			iTileResolution: { value : new THREE.Vector2( tileWidth, tileHeight ) },
			iResolution: { value: new THREE.Vector2( window.innerWidth, window.innerHeight ) },
			iMouse: { value: new THREE.Vector2( 0, 0 ) },
		}

		materials.push( new THREE.ShaderMaterial( { uniforms } ) );
	}

	return materials;
}

function loadShadersToMaterials(materials,loadingManager) {

    const shaderLoader = new THREE.FileLoader(loadingManager);
    for( let i = 0; i < nShaders; i++)
    {
    	// materials[i].vertexShader = vertexShader;
    	// materials[i].fragmentShader = shaderURLs[i];

    	// Load Vertex Shader
	    shaderLoader.load(shaders[i][0],
	        function (data) {
	    	    materials[i].vertexShader = data;
	    	}
    	);

    	// Load Fragment Shader
	    shaderLoader.load(shaders[i][1],
	        function (data) {
	    	    materials[i].fragmentShader = data;
	    	}
    	);
    }

}

function createMeshes(materials, nRows, nColumns){

	let meshes = [];
 
	const geometry = new THREE.PlaneGeometry( 1, 1 );

	// Generate meshes
	for (let i = 0; i < nShaders; i++)
	{
		const center = tileCenter(i);

		const mesh = new THREE.Mesh( geometry , materials[i] )

		mesh.scale.set( tileWidth, tileHeight, 1 );
		mesh.position.set( center[0], center[1] );

		meshes.push( mesh )
	}

	return meshes;
}


window.addEventListener('load',()=>{init(document.getElementById("container"))});

export default init;
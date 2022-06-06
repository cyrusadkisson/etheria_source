/* 
	 We want the map in this format:
	 {
		  "map":[
				[tile0, ... tile32], [tile17...tile65]...
		  ]
	 }
	 where each tile is 
	 {
		  "elevation": 134,
		  "owner": 0xabc123...,
		  "blocks": [[0,1,2,3,4]...]  // where [which,x,y,z,color]
		  ]
	 }
*/
var container;

var GENERATE_NEW_MAP = false;
var camera, controls, scene, renderer;
var mesh;

var mapsize = 33;

// this tiles setup won't be used if getting map from blockchain

var LEVELS = Math.cbrt(mapsize - 1) + 1;

var raycaster = new THREE.Raycaster();
var mouse = new THREE.Vector2();

document.addEventListener("DOMContentLoaded", function(event) {
	init();
	animate();
});

//Returns a random integer between min (included) and max (included)
//Using Math.round() will give you a non-uniform distribution!
function getRandomIntInclusive(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function init() {

	camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 1, 40000);
	camera.position.set(0, -200, 150);
	//camera.position.z = 200;

	controls = new THREE.OrbitControls(camera);
	controls.damping = 0.2;
	controls.addEventListener('change', render);

	scene = new THREE.Scene();
	// world

	if (GENERATE_NEW_MAP) {
		generateMap(mapsize, mapsize);

		for (var col = 0; col < mapsize; col++) {
			for (var row = 0; row < mapsize; row++) {

				//				if(NORMALIZE_ELEVATIONS)
				//					tiles[x][y].elevation = (tiles[x][y].elevation - min) * tiles[x][y].normalization_factor;
				drawMapHex(col, row);

				//				if(col === 15 && row === 9)
				//				{	
				//					var c = 0;
				//					var r = 0;
				//					var t = 0;
				//					var z = 0;
				//					var created = 0;
				//					var editedblock = false;
				//					
				//					while(created < 300)
				//					{
				//						t = getRandomIntInclusive(0,17);
				//						c = getRandomIntInclusive(0,7);
				//						r = getRandomIntInclusive(0,7);
				//						z = getRandomIntInclusive(0,100);
				//						editedblock = false;
				//						while(editedblock == false)
				//						{
				//							t = getRandomIntInclusive(0,17);
				//							c = getRandomIntInclusive(0,7);
				//							r = getRandomIntInclusive(0,7);
				//							z = getRandomIntInclusive(0,100);
				//							editedblock = editBlock(16,16,created,[t,c,r,z, getRandomIntInclusive(-128,127)]);
				//						}	
				//						created++;
				//					}	
				//				}
			}
		}

		// TESTS // DO NOT DELETE
		//		console.log('drawing 7 columns 0,0');
		editBlock(15, 9, 0, [0, 50, -62, 0, 47]); // succeed
		//		console.log('drawing 7 columns 0,66');
		//		editBlock(16,16,1,[0,0,66,0, getRandomIntInclusive(0,16777214)]); // succeed
		//		console.log('drawing 7 columns 49,33');
		//		editBlock(16,16,2,[0,49,33,0, getRandomIntInclusive(0,16777214)]); // succeed
		//		console.log('drawing 7 columns 49,-33');
		//		editBlock(16,16,3,[0,49,-33,0, getRandomIntInclusive(0,16777214)]); // succeed
		//		console.log('drawing 7 columns 0,-66');
		//		editBlock(16,16,4,[0,0,-66,0, getRandomIntInclusive(0,16777214)]); // succeed
		//		console.log('drawing 7 columns -50,-33');
		//		editBlock(16,16,5,[0,-50,-33,0, getRandomIntInclusive(0,16777214)]); // succeed
		//		console.log('drawing 7 columns -50,33');
		//		editBlock(16,16,6,[0,-50,33,0, getRandomIntInclusive(0,16777214)]); // succeed

		finishInitialRender();

	}
	else {
		for (var col = 0; col < mapsize; col++) {
			for (var row = 0; row < mapsize; row++) {

				//	    				if(NORMALIZE_ELEVATIONS)
				//	    					tiles[x][y].elevation = (tiles[x][y].elevation - min) * tiles[x][y].normalization_factor;
				drawMapHex(col, row);
				var index = col * mapsize + row;
				if (tiles[index].blocks) {
					for (var b = 0; b < tiles[index].blocks.length; b++) {
						if (tiles[index].blocks[b][3] >= 0) // z below 0 doesn't get drawn
						{
							console.log("drawing block col=" + col + " row=" + row + " " + JSON.stringify(tiles[index].blocks[b]));
							console.log("calling editBlock " + col + "," + row +
								" which=" + tiles[index].blocks[b][0] +
								" x=" + tiles[index].blocks[b][1] +
								" y=" + tiles[index].blocks[b][2] +
								" z=" + tiles[index].blocks[b][3] +
								" color=" + tiles[index].blocks[b][4]);
							editBlock(col, row, b,
								[tiles[index].blocks[b][0] * 1, // which
								tiles[index].blocks[b][1] * 1, // x
								tiles[index].blocks[b][2] * 1,  // y
								tiles[index].blocks[b][3] * 1,  // z
								tiles[index].blocks[b][4] * 1] // 256 color possibilities (0-255) each times 65536 will produce numbers in the range hex color range 0-16777216
							);
						}
					}
				}
			}
		}
		finishInitialRender();
	}
}

function finishInitialRender() {
	// lights
	light = new THREE.DirectionalLight(0xaaaaaa);
	light.position.set(1, 1, 1);
	scene.add(light);

	light = new THREE.AmbientLight(0xdddddd);
	scene.add(light);

	// renderer
	renderer = new THREE.WebGLRenderer({
		antialias: false
	});

	//renderer.setClearColor(scene.fog.color);
	renderer.setPixelRatio(window.devicePixelRatio);
	renderer.setSize(window.innerWidth, window.innerHeight);
	renderer.sortObjects = false;

	container = document.getElementById('container');
	container.appendChild(renderer.domElement);

	//

	window.addEventListener('resize', onWindowResize, false);
	window.addEventListener('mousemove', onMouseMove, false);
}

function onMouseMove(event) {

	// calculate mouse position in normalized device coordinates
	// (-1 to +1) for both components

	mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
	mouse.y = - (event.clientY / window.innerHeight) * 2 + 1;

	render();
}

function onWindowResize() {

	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();

	renderer.setSize(window.innerWidth, window.innerHeight);

	render();

}

function render() {

	// update the picking ray with the camera and mouse position	
	raycaster.setFromCamera(mouse, camera);

	// calculate objects intersecting the picking ray
	var intersects = raycaster.intersectObjects(scene.children, true);

	if (intersects.length > 0) {
		if (typeof intersects[0].object.userData.col !== "undefined") {
			var infotable = "<table style='width:100%'>";
			infotable = infotable + "<tr>";
			infotable = infotable + "	<td>";
			infotable = infotable + "		<b>col:</b> " + intersects[0].object.userData.col;
			infotable = infotable + "	</td>"
			infotable = infotable + "	<td>";
			infotable = infotable + "		<b>row:</b> " + intersects[0].object.userData.row;
			infotable = infotable + "	</td>"
			infotable = infotable + "	<td>";
			infotable = infotable + "		<b>type:</b> " + intersects[0].object.userData.tiletype;
			infotable = infotable + "	</td>"
			infotable = infotable + "	<td>";
			infotable = infotable + "		<b>elevation:</b> " + intersects[0].object.userData.elevation
			infotable = infotable + "	</td>"
			infotable = infotable + "</tr>";
			infotable = infotable + "<tr>";
			infotable = infotable + "	<td colspan=4>";
			infotable = infotable + "		<b>owner:</b> " + intersects[0].object.userData.owner;
			infotable = infotable + "	</td>"
			infotable = infotable + "</tr>";
			infotable = infotable + "<tr>";
			infotable = infotable + "	<td colspan=4>";
			infotable = infotable + "		<b>name:</b> " + intersects[0].object.userData.name;
			infotable = infotable + "	</td>"
			infotable = infotable + "</tr>";
			infotable = infotable + "<tr>";
			infotable = infotable + "	<td colspan=4>";
			infotable = infotable + "		<b>status:</b> " + intersects[0].object.userData.status;
			infotable = infotable + "	</td>"
			infotable = infotable + "</tr>";
			infotable = infotable + "</table>";
			$("#tileinfobodydiv").html(infotable);
		}
		else
			$("#tileinfobodydiv").html("Mouse over a tile to see more info.");

		if (typeof intersects[0].object.userData.which !== "undefined") {
			$("#blockinfobodydiv").html(
				"<b>index:</b> " + intersects[0].object.userData.blockindex + "<br>" +
				"<b>type:</b> " + intersects[0].object.userData.which + "<br>" +
				"<b>description:</b> " + intersects[0].object.userData.description + "<br>" +
				"<b>color:</b> " + intersects[0].object.userData.color + "<br>" +
				"<b>key hex:</b> " + intersects[0].object.userData.keyx + "," + intersects[0].object.userData.keyy + "," + intersects[0].object.userData.keyz
				//					+ "<br>" +
				//					"<b>occupies:</b> " + JSON.stringify(intersects[ 0 ].object.userData.occupies)
			);
		}
		else
			$("#blockinfobodydiv").html("Mouse over a block to see more info.");

		if (typeof intersects[0].object.userData.sequencenum !== "undefined") {
			$("#hexinfobodydiv").html(
				"<b>x:</b> " + intersects[0].object.userData.x + "<br>" +
				"<b>y:</b> " + intersects[0].object.userData.y + "<br>" +
				"<b>z:</b> " + intersects[0].object.userData.z + "<br>" +
				"<b>sequencenum:</b> " + intersects[0].object.userData.sequencenum
			);
		}
		else {
			$("#hexinfobodydiv").html("Mouse over a hex to see more info.")
		}
	}
	renderer.render(scene, camera);
}

function animate() {

	requestAnimationFrame(animate);
	controls.update();
}


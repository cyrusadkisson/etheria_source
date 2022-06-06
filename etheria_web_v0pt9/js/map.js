var DEPTH_VARIANCE_DECAY = 0.65; // higher = less variance
var CORNER_VARIANCE = 0.25;

function generateMap(width, height)
{
	console.log("generateMap");
	// ex: CORNER_VARIANCE of +-25% ->  .25 * 2 = .5  --> minus .25 is +- .25. Randomize it by 0-1, then multiply it by 128, then subtract from 128 
	tiles[0][0].elevation = 116; //Math.floor(128 - 128 * ((Math.random() * CORNER_VARIANCE * 2) - CORNER_VARIANCE));
	tiles[0][mapsize-1].elevation = 116; //Math.floor(128 - 128 * ((Math.random() * CORNER_VARIANCE * 2) - CORNER_VARIANCE));
	tiles[mapsize-1][0].elevation = 116; //Math.floor(128 - 128 * ((Math.random() * CORNER_VARIANCE * 2) - CORNER_VARIANCE));
	tiles[mapsize-1][mapsize-1].elevation = 116; //Math.floor(128 - 128 * ((Math.random() * CORNER_VARIANCE * 2) - CORNER_VARIANCE));
	generateMidpoints(0, 0, mapsize-1, mapsize-1, 1);
	//console.log(JSON.stringify(map));
//	var str = "";
//	for(var col = 0; col < 33; col++)
//	{
//		str = str + "mapelevationstorage.initElevations.sendTransaction(" + col + ",[";
//		for(var row = 0; row < 33; row++)
//		{
//			if(row != 32)
//				str = str + tiles[col][row].elevation + ",";
//			else
//				str = str + tiles[col][row].elevation + "], {from:eth.coinbase,gas:3000000});";
//		}	
//		str = str + "\n";
//	}	
//	console.log(str);
}

function generateMidpoints(sw_x, sw_y, ne_x, ne_y, depth)
{
	console.log("generateMidpoints");
//	console.log("number of total levels=" + LEVELS + " currentdepth=" + depth);
	var ne_elevation = tiles[ne_x][ne_y].elevation;
	var se_elevation = tiles[ne_x][sw_y].elevation;
	var sw_elevation = tiles[sw_x][sw_y].elevation;
	var nw_elevation = tiles[sw_x][ne_y].elevation;
//	console.log('generateMidpoint received square ' + sw_x + ', ' + sw_y + ' ' + ne_x + ', ' + ne_y);
//	console.log('with elevations ne=' + ne_elevation);
//	console.log('with elevations se=' + se_elevation);
//	console.log('with elevations sw=' + sw_elevation);
//	console.log('with elevations nw=' + nw_elevation);
	
	var newelevation = 0;  // if the span is, say, 50, generate number between 0-50 and then add the min elevation
//	console.log('*** new elevation=' + newelevation);
	var centerpointx = (ne_x - sw_x)/2 + sw_x;
	var centerpointy = (ne_y - sw_y)/2 + sw_y;
	
	var northx = centerpointx;
	var northy = ne_y;
	
	var eastx = ne_x;
	var easty = centerpointy;
	
	var southx = centerpointx;
	var southy = sw_y;
	
	var westx = sw_x;
	var westy = centerpointy;
	
	var color = '#ffffff';
	
//	console.log('*** north x,y=' + northx + ', ' + northy);
//	console.log('*** east x,y=' + eastx + ', ' + easty);
//	console.log('*** south x,y=' + southx + ', ' + southy);
//	console.log('*** west x,y=' + westx + ', ' + westy);
	if(depth === 1)
	{
		newelevation = 190;
		tiles[centerpointx][centerpointy].elevation = newelevation;
	}	
	else
	{	
		newelevation = (ne_elevation + se_elevation + sw_elevation + nw_elevation) / 4; // average of the 4 corners
		var perturbation = Math.random() * 1/(1+depth*DEPTH_VARIANCE_DECAY); // 1/1.2, 1/1.4, 1/1.6...
		if(Math.random() >= .5)
			perturbation = perturbation * -1; // half the time, flip it negative so we go below the average
//		console.log('*** perturbation=' + perturbation);
		tiles[centerpointx][centerpointy].elevation = Math.floor(newelevation - newelevation * perturbation); 
		if(tiles[centerpointx][centerpointy].elevation > 255)
			tiles[centerpointx][centerpointy].elevation = 255;
	}
	//drawHex2(centerpointx,centerpointy);
	
	tiles[northx][northy].elevation = Math.floor((nw_elevation + ne_elevation) / 2); 
	//drawHex2(northx,northy);
	
	tiles[eastx][easty].elevation = Math.floor((ne_elevation + se_elevation) / 2); 
	//drawHex2(eastx,easty);
	
	tiles[southx][southy].elevation = Math.floor((se_elevation + sw_elevation) / 2); 
	//drawHex2(southx,southy);
	
	tiles[westx][westy].elevation = Math.floor((sw_elevation + nw_elevation) / 2); 
	//drawHex2(westx,westy);
	
	//alert('just drew 5 points');
	
	if((ne_x - sw_x) < 3 || (ne_y - sw_y) < 3) 
	{
		// STOP CASE if width of grid is only 2 spaces, then stop. This is the last one.
	}
	else
	{
//		console.log('else recurse 4 times');
		
		generateMidpoints(sw_x, sw_y, centerpointx, centerpointy, depth+1);
		generateMidpoints(centerpointx, sw_y, ne_x, centerpointy, depth+1);
		generateMidpoints(centerpointx, centerpointy, ne_x, ne_y, depth+1);
		generateMidpoints(sw_x, centerpointy, centerpointx, ne_y, depth+1);
	}	
	return;
}

var mapsize = 33;
var tiles;
var tile;

$(document).ready(function(){
	console.log('doc ready');
	$('#colrow_form').submit(function(event) {
		console.log('on submit. ajaxing ' + $("#col_input").val() + "  " + $('#row_input').val());
		$.ajax({ 
			type: 'GET', 
			url: '/map', 
			dataType: 'json',
			timeout: 100000,
			async: true, // same origin, so this is ok 
			success: function (data, status) {
				console.log('back ' + $("#col_input").val() + "  " + $('#row_input').val());
				tiles = data;
				tile = tiles[$("#col_input").val()][$('#row_input').val()];
	    	
		    	var infotable = "<table style='width:100%;border-padding:1px;background-color:black'>";
		    	infotable = infotable + "<tr>";
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>index</td>"
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>type</td>"
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>picture</td>"
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>x</td>"
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>y</td>"
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>z</td>"
	    		infotable = infotable + "	<td style='padding:10px;font-weight:bold;font-size:18px;text-align:center;background-color:white'>color</td>"
	    		infotable = infotable + "</tr>";
		    	for(var i = 0; i < tile.blocks.length; i++)
		    	{
		    		infotable = infotable + "<tr>";
		    		infotable = infotable + "	<td style='text-align:center;background-color:white'>";
		    		infotable = infotable + "		" + i;
		    		infotable = infotable + "	</td>"
		    		infotable = infotable + "	<td style='text-align:center;background-color:white'>";
		    		infotable = infotable + "		type #" + tile.blocks[i][0] + "<br><br>\"" + blockdefs[tile.blocks[i][0]].description + "\"";
		    		infotable = infotable + "	</td>"
		    		infotable = infotable + "	<td  style='text-align:center;background-color:white;width:150px'>";
		    		infotable = infotable + "		<img src='images/block" + tile.blocks[i][0] + ".png' style='width:150px;height:100px'>";
		    		infotable = infotable + "	</td>"
		    		infotable = infotable + "	<td style='text-align:center;background-color:white'>";
		    		infotable = infotable + "		" + tile.blocks[i][1];
		    		infotable = infotable + "	</td>"
		    		infotable = infotable + "	<td style='text-align:center;background-color:white'>";
		    		infotable = infotable + "		" + tile.blocks[i][2];
		    		infotable = infotable + "	</td>"
		    		infotable = infotable + "	<td style='text-align:center;background-color:white'>";
		    		infotable = infotable + "		" + tile.blocks[i][3];
		    		infotable = infotable + "	</td>"
//					console.log("i=" + i);
//					console.log("tile.blocks[i]=" + tile.blocks[i]);
//					console.log("tile.blocks[i][4]=" + tile.blocks[i][4]);
//					console.log("tile.blocks[i][4]+128=" + (tile.blocks[i][4]*1+128));
		    		infotable = infotable + "	<td style='background-color:#" + colors[tile.blocks[i][4]*1+128] + ";text-align:center'>";
					infotable = infotable + "		<span style='color:white;padding-right:10px'>" + (tile.blocks[i][4]) + "</span>";
					infotable = infotable + "		<span style='color:black'>" + (tile.blocks[i][4]) + "</span> "
					infotable = infotable + "	</td>"
		    		infotable = infotable + "</tr>";
		    	}	
		    	infotable = infotable + "</table>";
		    	$('#tile_div').html(infotable);
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		    	console.log("elevations ajax error");
		    }
		});
		return false;
	});
});

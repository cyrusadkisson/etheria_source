/*

Folder name = NKNVELSC (Non-killable, non-viable, Etheria-like smart contract)

WARNING! This test contract is live on the chain, can't be killed but is FATALLY BUGGED.
______ _____   _   _ _____ _____  ______ _   ___   __
|  _  \  _  | | \ | |  _  |_   _| | ___ \ | | \ \ / /
| | | | | | | |  \| | | | | | |   | |_/ / | | |\ V / 
| | | | | | | | . ` | | | | | |   | ___ \ | | | \ /  
| |/ /\ \_/ / | |\  \ \_/ / | |   | |_/ / |_| | | |  
|___/  \___/  \_| \_/\___/  \_/   \____/ \___/  \_/  
                                                     
There is no wrapper. There is no official support/website. 
Anything you may see for Etheria 0xa2f63 is a SCAM!
No wrapper or anything else can fix the underlying bug.
It is FATAL, not cosmetic. 
If people buy tiles here (for 1 ETH), they can be stolen by anyone at any time for 1 ETH (which goes to the contract creator address, not the tile owner).
(A corollary to this is the creator can steal the tiles *for free* at any time.)

BUGGED Etheria v0.85
Block 399334 
Oct-17-2015 09:45:45 PM +UTC
0xa2f63e28172ebf2477f4c1a87aed68aaa3ebbe3d

While I couldn't get an exact source-to-bytecode match, there are 4 code commits in Github from Oct 17, 2015...
	https://github.com/cyrusadkisson/etheriaSource/blob/c74ca5d7fb32a973165a05d57587f880722a959f/contracts/etheria.sol
	https://github.com/cyrusadkisson/etheriaSource/blob/7f1fec8646e97e0cb457792a0dadb37c343cae85/contracts/etheria.sol
	https://github.com/cyrusadkisson/etheriaSource/blob/e2fe46f9c97075eaac6fa0e14c2ca063779899df/contracts/etheria.sol
	https://github.com/cyrusadkisson/etheriaSource/blob/f638cbe6d3b1d4947ec662a1fa1c81c5071263e9/contracts/etheria.sol
...and all 4 have the same catastrophic bug in this snippet created by a bad cut+paste:

function makeOffer(uint8 col, uint8 row)
{
    	if(msg.value < 10000000000000000 || msg.value > 1208925819614629174706175) // .01 ether up to (2^80 - 1) wei is the valid range
    	{
    		...
    	}
    	else if(mer.getElevation(col,row) >= 125 && tiles[col][row].owner == address(0) ||  // if unowned and above sea level, accept offer of 1 ETH immediately
---->		   (block.number - tiles[col][row].lastfarm) > 100000) 					// or if it's been more than 100000 blocks since the tile was last farmed
    	{
    		if(msg.value != 1000000000000000000) // 1 ETH is the starting value. If not enough or too much...
    		{
    			...
    		}	
    		else
    		{
    			creator.send(msg.value);     		 // this was a valid offer, send money to contract owner
    			tiles[col][row].owner = msg.sender;  // set tile owner to the buyer
    			farmTile(col,row); 					 // always immediately farm the tile
    			return;		
    		}	
    	}	
    	...
}

Explanation of bug: 

makeOffer serves two purposes - (a) initial purchases and then (b) bidding on tiles that are already owned
After a check that the incoming offer value is in the valid range, the logic SHOULD move on to check

	is the tile land (not water) AND is the tile unowned

If both are true, the tile is "sold" to the account making the offer of exactly 1 ETH. (This 1 ETH goes to the contract creator.)

So what's the bug? Look at the "extra" line marked by "---->" above. Apparently, I cut and pasted some logic from the block farming mechanism. 
It has no business being there at all. This bugged makeOffer now does the following bad conditional check

	is the tile land (not water) AND is the tile unowned ***OR*** has it been 100,000 ethereum blocks since last farm

this will, ultimately, always resolve to 

	true && false || true
	
which is really just
	
	true	
  
*** Thus, makeOffer + 1 ETH can be used to steal tiles and all the "sale" proceeds go to the contract deployer. ***
*** Ergo, the creator account can steal tiles for free. ***

To make sure, I used 0xcf684 (the creator address) to make a 1 ETH offer on a tile owned by 0x916. 
Without the bug, the tile should remain owned by 0x916 and get an offer of 1 ETH into the system.
Instead, the contract gave the tile to 0xcf684 and sent 1 ETH to the contract creator, not even 0x916.
BUG PROOF: https://etherscan.io/tx/0x38526bbfbfdc06ef3980d3a7593f46c6b34c33dd9d13a40a9b36395bc1841f28

Full function hash analysis of code live on the chain:
{
    "address": "0xa2f63e28172ebf2477f4c1a87aed68aaa3ebbe3d",
    "blockNumber": 399334,
    "54385526-setStatus(uint8,uint8,string)": false,
    "2ef761d3-buyTile(uint8,uint8)": false,
    "8cae1374-editBlock(uint8,uint8,uint256,int8[5])": true,
    "f2a75fe4-empty()": false,
    "90fd53ec-farmTile(uint8,uint8,int8)": false,
    "fa93019c-getBlocks(uint8,uint8)": true,
    "8435be4b-getLastFarm(uint8,uint8)": false,
    "2d49ffcd-getLocked()": false,
    "a55cab95-getName(uint8,uint8)": false,
    "e039e4a1-getOwner(uint8,uint8)": false,
    "d39eb301-getStatus(uint8,uint8)": false,
    "182db370-getWhatHappened()": true,
    "41c0e1b5-kill()": false,
    "10c1952f-setLocked()": false,
    "93eec1fb-setName(uint8,uint8,string)": false,
    "7d5fec5a-setOwner(uint8,uint8,address)": false,
    "a4741f48-acceptOffer(uint8,uint8,uint8,uint256)": false,
    "7f40458a-deleteOffer(uint8,uint8,uint8,uint256)": false,
    "959eac47-farmTile(uint8,uint8)": true,
    "6a864559-getOfferers(uint8,uint8)": true,
    "c7dafc78-getOffers(uint8,uint8)": true,
    "4b42d208-getUint8FromByte32(bytes32,uint8)": true,
    "6266b514-makeOffer(uint8,uint8)": true,
    "a5ffca0e-acceptOffer(uint8,uint8,uint8)": true,
    "a713081c-rejectOffer(uint8,uint8,uint8)": true,
    "edffcd57-retractOffer(uint8,uint8)": true,
    "a0e67e2b-getOwners()": true,
    "049b7852-getElevations()": false,
    "54746dac-initBlockDef(uint8,int8[3][8],int8[3][])": false,
    "f25e675d-initElevations(uint8,uint8[17])": false,
    "5c24b074-setInitializer(address)": false,
    "46c52b1a-blockHexCoordsValid(int8,int8)": false,
    "3f40a42b-initOccupado(uint256,uint256)": false,
    "d6c13297-initTiles(uint8,uint8[17])": false,
    "85c574f3-touchesAndAvoidsOverlap(uint8,uint8,int8,int8,int8,int8)": false,
    "b3955935-wouldFallOutside(int8,int8,int8)": false,
    "7203fb00-editBlock(uint8,uint8,uint256,int8[7])": false,
    "5f264591-initializeTiles(uint8,uint8[17])": false,
    "e87305eb-touchesAnother(uint8,uint8,int8,int8,int8,int8)": false,
    "a89425ab-wouldOverlap(uint8,uint8,int8,int8,int8,int8)": false,
    "0a786f34-getIlliquidBalance()": false,
    "8ad40912-getLiquidBalance()": false,
    "74ca9fbe-retrieveLiquidBalance()": false,
    "a364c21f-getBlocksForTile(uint8,uint8)": false,
    "bd9a548b-getPrices()": false,
    "3eb032cc-initializeRow(uint8,uint8[17])": false,
    "1a0cda6f-addBlock(uint8,uint8,int8[7])": false,
    "17513d49-initializeElevations(uint8,uint8[17])": false,
    "cb7b1469-initializeOwners(uint8)": false,
    "2f6d498f-initializePrices(uint8)": false,
    "a0ad10a6-initializeOwners(uint8[])": false,
    "d810612b-setElevations(uint8,uint8[33])": false,
    "1a092541-getDescription()": false,
    "232a8ec6-getDescription(uint8,uint8)": false,
    "7ec843dd-getDescriptor(uint8,uint8)": false,
    "4166c1fd-getElevation(uint8,uint8)": true,
    "6961807e-setDescriptor(uint8,uint8,address)": false,
    "0878bc51-getAttachesto(uint8)": true,
    "1bcf5758-getOccupies(uint8)": true,
    "d87a1166-initAttachesto(uint8,int8[48])": false,
    "e579763b-initOccupies(uint8,int8[24])": false,
    "57f10d71-initElevations(uint8,uint8[33])": false,
    "6f366805-makeOffer(uint8,uint8,uint80)": false,
    "dba69519-initializeTiles(uint8[],uint8[17])": false,
    "getLockedResult": null
}

Just the "true" function hashes
{
	"a5ffca0e-acceptOffer(uint8,uint8,uint8)": true,
    "8cae1374-editBlock(uint8,uint8,uint256,int8[5])": true,
    "959eac47-farmTile(uint8,uint8)": true,
    "0878bc51-getAttachesto(uint8)": true,
    "fa93019c-getBlocks(uint8,uint8)": true,
    "4166c1fd-getElevation(uint8,uint8)": true,
    "1bcf5758-getOccupies(uint8)": true,
    "6a864559-getOfferers(uint8,uint8)": true,
    "c7dafc78-getOffers(uint8,uint8)": true,
    "a0e67e2b-getOwners()": true,
    "4b42d208-getUint8FromByte32(bytes32,uint8)": true,
    "182db370-getWhatHappened()": true,
    "6266b514-makeOffer(uint8,uint8)": true,
    "a713081c-rejectOffer(uint8,uint8,uint8)": true,
    "edffcd57-retractOffer(uint8,uint8)": true,
}

var etheriaAddress = "0xa2f63e28172ebf2477f4c1a87aed68aaa3ebbe3d";
var abi =[{"constant":false,"inputs":[{"name":"which","type":"uint8"}],"name":"getAttachesto","outputs":[{"name":"","type":"int8[48]"}],"type":"function","payable":true,"stateMutability":"payable"},{"constant":true,"inputs":[],"name":"getWhatHappened","outputs":[{"name":"","type":"uint8"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":false,"inputs":[{"name":"which","type":"uint8"}],"name":"getOccupies","outputs":[{"name":"","type":"int8[24]"}],"type":"function","payable":true,"stateMutability":"payable"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getElevation","outputs":[{"name":"","type":"uint8"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":true,"inputs":[{"name":"_b32","type":"bytes32"},{"name":"byteindex","type":"uint8"}],"name":"getUint8FromByte32","outputs":[{"name":"","type":"uint8"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"makeOffer","outputs":[],"type":"function","payable":true,"stateMutability":"payable"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOfferers","outputs":[{"name":"","type":"address[]"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"index","type":"uint256"},{"name":"_block","type":"int8[5]"}],"name":"editBlock","outputs":[],"type":"function","payable":true,"stateMutability":"payable"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"farmTile","outputs":[],"type":"function","payable":true,"stateMutability":"payable"},{"constant":true,"inputs":[],"name":"getOwners","outputs":[{"name":"","type":"address[33][33]"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"}],"name":"acceptOffer","outputs":[],"type":"function","payable":true,"stateMutability":"payable"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"}],"name":"rejectOffer","outputs":[],"type":"function","payable":true,"stateMutability":"payable"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOffers","outputs":[{"name":"","type":"uint256[]"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"retractOffer","outputs":[],"type":"function","payable":true,"stateMutability":"payable"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getBlocks","outputs":[{"name":"","type":"int8[5][]"}],"type":"function","payable":false,"stateMutability":"view"},{"inputs":[],"type":"constructor","payable":true,"stateMutability":"payable"},{"type":"fallback","payable":true,"stateMutability":"payable"}];
var etheria = new web3.eth.Contract(abi, etheriaAddress);

The following code is as close as I could get it. All function hashes match.
Doesn't matter. Fatal bug exists as described above.

*/

contract BlockDefRetriever 
{
	function getOccupies(uint8 which) returns (int8[24])
	{}
	function getAttachesto(uint8 which) returns (int8[48])
    {}
}

contract MapElevationRetriever 
{
	function getElevation(uint8 col, uint8 row) constant returns (uint8)
	{}
}

contract Etheria is BlockDefRetriever,MapElevationRetriever
{
	
	/***
	 *     _____             _                  _     _       _ _   
	 *    /  __ \           | |                | |   (_)     (_) |  
	 *    | /  \/ ___  _ __ | |_ _ __ __ _  ___| |_   _ _ __  _| |_ 
	 *    | |    / _ \| '_ \| __| '__/ _` |/ __| __| | | '_ \| | __|
	 *    | \__/\ (_) | | | | |_| | | (_| | (__| |_  | | | | | | |_ 
	 *     \____/\___/|_| |_|\__|_|  \__,_|\___|\__| |_|_| |_|_|\__|
	 *                                                              
	 */
    uint8 mapsize = 33;
    Tile[33][33] tiles;
    address creator;
        
    struct Tile 
    {
    	address owner;
    	address[] offerers;
    	uint[] offers;
    	int8[5][] blocks; //0 = which,1 = blockx,2 = blocky,3 = blockz, 4 = color
    	uint lastfarm;
    	int8[3][] occupado;
    }
    
    BlockDefRetriever bds;
    MapElevationRetriever mer;
    
    function Etheria() {
    	creator = msg.sender;
    	bds = BlockDefRetriever(0x782bdf7015b71b64f6750796dd087fde32fd6fdc); 
    	mer = MapElevationRetriever(0xc35a4e966bf792734a25ea524448ea54de385e4e);
    }
    
    function getOwners() constant returns(address[33][33])
    {
        address[33][33] memory owners;
        for(uint8 row = 0; row < mapsize; row++)
        {
        	for(uint8 col = 0; col < mapsize; col++)
        	{
        	    owners[col][row] = tiles[col][row].owner; 
        	}	
        }	
    	return owners;
    }
    
    /***
     *    ______                     _   _ _                        _ _ _     _     _            _        
     *    |  ___|                   | | (_) |                      | (_) |   | |   | |          | |       
     *    | |_ __ _ _ __ _ __ ___   | |_ _| | ___  ___      ___  __| |_| |_  | |__ | | ___   ___| | _____ 
     *    |  _/ _` | '__| '_ ` _ \  | __| | |/ _ \/ __|    / _ \/ _` | | __| | '_ \| |/ _ \ / __| |/ / __|
     *    | || (_| | |  | | | | | | | |_| | |  __/\__ \_  |  __/ (_| | | |_  | |_) | | (_) | (__|   <\__ \
     *    \_| \__,_|_|  |_| |_| |_|  \__|_|_|\___||___( )  \___|\__,_|_|\__| |_.__/|_|\___/ \___|_|\_\___/
     *                                                |/                                                  
     *                                                                                                    
     */
    // see EtheriaHelper for non-refucktored version of this algorithm.
    function getUint8FromByte32(bytes32 _b32, uint8 byteindex) public constant returns(uint8) {
    	uint numdigits = 64;
    	uint buint = uint(_b32);
    	uint upperpowervar = 16 ** (numdigits - (byteindex*2)); 		// @i=0 upperpowervar=16**64 (SEE EXCEPTION BELOW), @i=1 upperpowervar=16**62, @i upperpowervar=16**60
    	uint lowerpowervar = 16 ** (numdigits - 2 - (byteindex*2));		// @i=0 upperpowervar=16**62, @i=1 upperpowervar=16**60, @i upperpowervar=16**58
    	uint postheadchop;
    	if(byteindex == 0)
    		postheadchop = buint; 								//for byteindex 0, buint is just the input number. 16^64 is out of uint range, so this exception has to be made.
    	else
    		postheadchop = buint % upperpowervar; 				// @i=0 _b32=a1b2c3d4... postheadchop=a1b2c3d4, @i=1 postheadchop=b2c3d4, @i=2 postheadchop=c3d4
    	uint remainder = postheadchop % lowerpowervar; 			// @i=0 remainder=b2c3d4, @i=1 remainder=c3d4, @i=2 remainder=d4
    	uint evenedout = postheadchop - remainder; 				// @i=0 evenedout=a1000000, @i=1 remainder=b20000, @i=2 remainder=c300
    	uint b = evenedout / lowerpowervar; 					// @i=0 b=a1 (to uint), @i=1 b=b2, @i=2 b=c3
    	return uint8(b);
    }
    
    function farmTile(uint8 col, uint8 row)
    {
        if(tiles[col][row].owner != msg.sender)
            return;
        if((block.number - tiles[col][row].lastfarm) < 4320) // a day's worth of blocks hasn't passed yet. can only farm once a day. (Assumes block times of 20 seconds.)
        	return;
        bytes32 lastblockhash = block.blockhash(block.number - 1);
    	for(uint8 i = 0; i < 20; i++)
    	{
            tiles[col][row].blocks.length+=1;
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][0] = int8(getUint8FromByte32(lastblockhash,i) % 32); // which, guaranteed 0-31
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][1] = 0; // x
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][2] = 0; // y
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][3] = -1; // z
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][4] = 0; // color
    	}
    	tiles[col][row].lastfarm = block.number;
    }
    
    // SEVERAL CHECKS TO BE PERFORMED
    // 1. DID THE OWNER SEND THIS MESSAGE?
    // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN AFTER SHOWING
    // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
    // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
    // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER?
    
    function editBlock(uint8 col, uint8 row, uint index, int8[5] _block)  
    {
        if(tiles[col][row].owner != msg.sender) // 1. DID THE OWNER SEND THIS MESSAGE?
        {
        	whathappened = 1;
        	return;
        }
        if(_block[3] < -1) // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN
        {
        	whathappened = 2;
        	return;
        }
        
        _block[0] = tiles[col][row].blocks[index][0]; // can't change the which, so set it to whatever it already was

        bool touches;
        
        int8[24] memory wouldoccupy = bds.getOccupies(uint8(_block[0]));
        int8[24] memory didoccupy = bds.getOccupies(uint8(_block[0]));
//        int8[3][8] memory wouldoccupy = bds.getOccupies(uint8(_block[0])); // start would and did with the base set of 8 occupancies
//        int8[3][8] memory didoccupy = bds.getOccupies(uint8(_block[0]));
        
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the wouldoccupy and the didoccupy
     	{
     		wouldoccupy[b] = wouldoccupy[b]+_block[1];
     		wouldoccupy[b+1] = wouldoccupy[b+1]+_block[2];
     		if(wouldoccupy[1] % 2 != 0 && wouldoccupy[b+1] % 2 != 0) // if anchor y and this hex y are both odd,
     			wouldoccupy[b] = wouldoccupy[b]+1;  			   // then offset x by +1
     		wouldoccupy[b+2] = wouldoccupy[b+2]+_block[3];
     		
     		if(!blockHexCoordsValid(wouldoccupy[b], wouldoccupy[b+1])) // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
    		{
    			whathappened = 3;
    			return;
    		}
     		for(uint o = 0; o < tiles[col][row].occupado.length; o++)  // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
        	{
    			if(wouldoccupy[b] == tiles[col][row].occupado[o][0] && wouldoccupy[b+1] == tiles[col][row].occupado[o][1] && wouldoccupy[b+2] == tiles[col][row].occupado[o][2]) // do the x,y,z entries of each match?
    			{
    				whathappened = 4;
    				return; // this hex conflicts. The proposed block does not avoid overlap. Return false immediately.
    			}
        	}
    		if(touches == false && wouldoccupy[b+2] == 0)  // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER? (GROUND ONLY FOR NOW)
    		{
    			touches = true; // once true, always true til the end of this method
    		}	
     		
     		didoccupy[b] = didoccupy[b]+tiles[col][row].blocks[index][1];
     		didoccupy[b+1] = didoccupy[b+1]+tiles[col][row].blocks[index][2];
     		if(didoccupy[1] % 2 != 0 && didoccupy[b+1] % 2 != 0) // if anchor y and this hex y are both odd,
     			didoccupy[b] = didoccupy[b]+1; 					 // then offset x by +1
     		didoccupy[b+2] = didoccupy[b+2]+tiles[col][row].blocks[index][3];
     	}
        
        // EVERYTHING CHECKED OUT, WRITE OR OVERWRITE THE HEXES IN OCCUPADO
 
      	if(tiles[col][row].blocks[index][3] >= 0) // If the previous z was greater than 0 (i.e. not hidden) ...
     	{
     		// get the previous 8 hex locations
         	for(uint8 l = 0; l < 24; l+=3) // loop 8 times,find the previous occupado entries and overwrite them
         	{
         		for(o = 0; o < tiles[col][row].occupado.length; o++)
         		{
         			if(didoccupy[l] == tiles[col][row].occupado[o][0] && didoccupy[l+1] == tiles[col][row].occupado[o][1] && didoccupy[l+2] == tiles[col][row].occupado[o][2]) // x,y,z equal?
         			{
         				tiles[col][row].occupado[o][0] = wouldoccupy[l]; // found it. Overwrite it
         				tiles[col][row].occupado[o][1] = wouldoccupy[l+1];
         				tiles[col][row].occupado[o][2] = wouldoccupy[l+2];
         			}
         		}
         	}
     	}
     	else // previous block was hidden
     	{
     		for(uint8 ll = 0; ll < 24; ll+=3) // add the 8 new hexes to occupado
         	{
     			tiles[col][row].occupado.length++;
     			tiles[col][row].occupado[tiles[col][row].occupado.length-1][0] = wouldoccupy[ll];
     			tiles[col][row].occupado[tiles[col][row].occupado.length-1][1] = wouldoccupy[ll+1];
     			tiles[col][row].occupado[tiles[col][row].occupado.length-1][2] = wouldoccupy[ll+2];
         	}
     	}
      	
     	tiles[col][row].blocks[index] = _block;
     	whathappened = 5;
    	return;
    }
    
    function getBlocks(uint8 col, uint8 row) constant returns (int8[5][])
    {
    	return tiles[col][row].blocks;
    }
    
    // TODO:
    // DONE block texturing
    // DONE angle camera
    // DONE block edit validation coordinate constraints in JS
    // DONE block edit validation must touch, no overlap in JS
    // block edit validation coordinate constraints in solidity
    // block edit validation must touch, no overlap in solidity
    // DONE block lookup caching 
    // register name for owner
   
    // FULL GAME TODO:
    // Fitness vote
    // Cast threat
    // chat
    // messaging
    // block trading
    // reclamation
    // price modifier
    
    uint8 whathappened;
    
    function getWhatHappened() public constant returns (uint8)
    {
    	return whathappened;
    }
    
    function blockHexCoordsValid(int8 x, int8 y) private constant returns (bool)
    {
    	if(-33 <= y && y <= 33)
    	{
    		if(y % 2 != 0 ) // odd
    		{
    			if(-50 <= x && x <= 49)
    				return true;
    			
    		}
    		else // even
    		{
    			if(-49 <= x && x <= 49)
    				return true;
    			
    		}	
    	}	
    	else
    	{	
    		uint8 absx;
			uint8 absy;
			if(x < 0)
				absx = uint8(x*-1);
			else
				absx = uint8(x);
			if(y < 0)
				absy = uint8(y*-1);
			else
				absy = uint8(y);
    		if((y >= 0 && x >= 0) || (y < 0 && x > 0)) // first or 4th quadrants
    		{
    			if(y % 2 != 0 ) // odd
    			{
    				if (((absx*2) + (absy*3)) <= 198)
    					return true;
    				
    			}	
    			else	// even
    			{
    				if ((((absx+1)*2) + ((absy-1)*3)) <= 198)
    					return true;
    				
    			}
    		}
    		else
    		{	
    			if(y % 2 == 0 ) // even
    			{
    				if (((absx*2) + (absy*3)) <= 198)
    					return true;
    				
    			}	
    			else	// odd
    			{
    				if ((((absx+1)*2) + ((absy-1)*3)) <= 198)
    					return true;
    				
    			}
    		}
    	}
    	return false;
    }
    
    /***
     *     _____  __  __              
     *    |  _  |/ _|/ _|             
     *    | | | | |_| |_ ___ _ __ ___ 
     *    | | | |  _|  _/ _ \ '__/ __|
     *    \ \_/ / | | ||  __/ |  \__ \
     *     \___/|_| |_| \___|_|  |___/
     *                                
     *                                
     */
    
    function makeOffer(uint8 col, uint8 row)
    {
    	if(msg.value < 10000000000000000 || msg.value > 1208925819614629174706175) // .01 ether up to (2^80 - 1) wei is the valid range
    	{
    		if(!(msg.value == 0))
    			msg.sender.send(msg.value); 		// return their money
    		whathappened = 10;
    		return;
    	}
    	else if(mer.getElevation(col,row) >= 125 && tiles[col][row].owner == address(0) ||  // if unowned and above sea level, accept offer of 1 ETH immediately
    			   (block.number - tiles[col][row].lastfarm) > 100000) 					// or if it's been more than 100000 blocks since the tile was last farmed 
    	{																				// ^-- 2022 note: This was a weird cut-paste error. Block farming has nothing 
    																					// to do with tile purchasing. Anyway, it's default/always true which allows the 
    																					// creator to steal tiles for free or anyone else to steal tiles for 1 ETH that 
    																					// goes to the creator, not the tile owner.	
    																					// With this cut/paste error we can't get to the "else" to make a real offer.		
    		if(msg.value != 1000000000000000000) // 1 ETH is the starting value. If not enough or too much...
    		{
    			msg.sender.send(msg.value); 	 // return their money
    			whathappened = 11;
        		return;
    		}	
    		else
    		{
    			creator.send(msg.value);     		 // this was a valid offer, send money to contract owner
    			tiles[col][row].owner = msg.sender;  // set tile owner to the buyer
    			farmTile(col,row); 					 // always immediately farm the tile
    			whathappened = 12;
    			return;		
    		}	
    	}	
    	else
    	{
    		if(tiles[col][row].offerers.length < 10) // this tile can only hold 10 offers at a time
    		{
    			for(uint8 i = 0; i < tiles[col][row].offerers.length; i++)
    			{
    				if(tiles[col][row].offerers[i] == msg.sender) // user has already made an offer. Update it and return;
    				{
    					msg.sender.send(tiles[col][row].offers[i]); // return their previous money
    					tiles[col][row].offers[i] = msg.value; // set the new offer
    					whathappened = 13;
    					return;
    				}
    			}	
    			// the user has not yet made an offer
    			tiles[col][row].offerers.length++; // make room for 1 more
    			tiles[col][row].offers.length++; // make room for 1 more
    			tiles[col][row].offerers[tiles[col][row].offerers.length - 1] = msg.sender; // record who is making the offer
    			tiles[col][row].offers[tiles[col][row].offers.length - 1] = msg.value; // record the offer
    			whathappened = 14;
        		return;
    		}	
    		whathappened = 15;
    		return;
    	}
    	whathappened = 16;
		return;
    }
    
    function retractOffer(uint8 col, uint8 row) // retracts the first offer in the array by this user.
    {
        for(uint8 i = 0; i < tiles[col][row].offerers.length; i++)
    	{
    		if(tiles[col][row].offerers[i] == msg.sender) // this user has an offer on file. Remove it.
    			removeOffer(col,row,i);
    	}	
    }
    
    function rejectOffer(uint8 col, uint8 row, uint8 i) // index 0-10
    {
    	if(tiles[col][row].owner != msg.sender) // only the owner can reject offers
    		return;
    	removeOffer(col,row,i);
		return;
    }
    
    function removeOffer(uint8 col, uint8 row, uint8 i) private // index 0-10, can't be odd
    {
    	// return the money
        tiles[col][row].offerers[i].send(tiles[col][row].offers[i]);
    			
    	// delete user and offer and reshape the array
    	delete tiles[col][row].offerers[i];   // zero out user
    	delete tiles[col][row].offers[i];   // zero out offer
    	for(uint8 j = i+1; j < tiles[col][row].offerers.length; j++) // close the arrays after the gap
    	{
    	    tiles[col][row].offerers[j-1] = tiles[col][row].offerers[j];
    	    tiles[col][row].offers[j-1] = tiles[col][row].offers[j];
    	}
    	tiles[col][row].offerers.length--;
    	tiles[col][row].offers.length--;
    	return;
    }
    
    function acceptOffer(uint8 col, uint8 row, uint8 i) // accepts the offer at index (1-10)
    {
    	uint offeramount = tiles[col][row].offers[i];
    	uint housecut = offeramount / 10;
    	creator.send(housecut);
    	tiles[col][row].owner.send(offeramount-housecut); // send offer money to oldowner
    	tiles[col][row].owner = tiles[col][row].offerers[i]; // new owner is the offerer
    	delete tiles[col][row].offerers; // delete all offerers
    	delete tiles[col][row].offers; // delete all offers
    	return;
    }
    
    function getOfferers(uint8 col, uint8 row) constant returns (address[])
    {
    	return tiles[col][row].offerers;
    }
    
    function getOffers(uint8 col, uint8 row) constant returns (uint[])
    {
    	return tiles[col][row].offers;
    }
    
}
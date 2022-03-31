// Solidity 0.8.7-e28d00a7 optimization 200 (default)
// verified with etherscan
// address: 0x629a493a94b611138d4bee231f94f5c08ab6570a

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Etheria {
    function getOwner(uint8 col, uint8 row) external view returns(address);
    function getOfferers(uint8 col, uint8 row) external view returns (address[] memory);
    function getOffers(uint8 col, uint8 row) external view returns (uint[] memory);  
    function setName(uint8 col, uint8 row, string memory _n) external;
    function setStatus(uint8 col, uint8 row, string memory _s) external payable;
    function makeOffer(uint8 col, uint8 row) external payable;
    function acceptOffer(uint8 col, uint8 row, uint8 index, uint amt) external;
    function deleteOffer(uint8 col, uint8 row, uint8 index, uint amt) external;
}

contract EtheriaWrapper1pt0 is Ownable, ERC721 {

    address public _etheriaAddress;
    Etheria public _etheria;

    mapping (uint256 => address) public wrapInitializers;
   
    constructor() payable ERC721("Etheria Wrapper v1pt0 2015-10-22", "EW10") {
		_etheriaAddress = 0xe414716F017b5c1457bF98e985BCcB135DFf81F2;
		_etheria = Etheria(_etheriaAddress);
        _baseTokenURI = "https://etheria.world/metadata/v1pt0/";
		_baseTokenExtension = ".json";
    }
    
    receive() external payable
    {
        // Only accept from Etheria contract
        require(_msgSender() == _etheriaAddress, "EW10: ETH sender isn't Etheria contract");
    }

    event WrapStarted(address indexed addr, uint256 indexed _locationID);
    event WrapFinished(address indexed addr, uint256 indexed _locationID);
    event Unwrapped(address indexed addr, uint256 indexed _locationID);
    event NameSet(address indexed addr, uint256 indexed _locationID, string name);
    event StatusSet(address indexed addr, uint256 indexed _locationID, string status);
    event OfferRejected(address indexed addr, uint256 indexed _locationID, uint offer, address offerer);
    event OfferRetracted(address indexed addr, uint256 indexed _locationID); // offerer is always address(this) and amount always 0.01 ETH

    function _getIndex(uint8 col, uint8 row) internal pure returns (uint256) {
        require(col <= uint8(32) && row <= uint8(32), "EW10: Invalid col and/or row. Valid range is 0-32"); // uint8 prevents sub-0 automatically
        return (uint256(col) * uint256(33)) + uint256(row);
    }

    // ***** Why are v0.9 and v1.0 wrappable while v1.1 and v1.2 are not? (as of March 2022) *****
    //
    // Etheria was developed long before any NFT exchanges existed. As such, in versions v0.9 and 
    // v1.0, I added internal exchange logic (hereinafter the "offer system") to facilitate trading before abandoning
    // it in favor of a simple "setOwner" function in v1.1 and v1.2.
    // 
    // While this "offer system" was really poorly designed and clunky (the result of a manic episode of moving fast
    // and "testing in production"), it does actually work and work reliably if the proper precautions are taken.
    // 
    // What's more, this "offer system" used msg.sender (v0.9 and v1.0) instead of tx.origin (v1.1 and v1.2) which
    // which means v0.9 and v1.0 tiles are ownable by smart contracts... i.e. they are WRAPPABLE
    //
    // Wrappability means that this terrible "offer system" will be entirely bypassed after wrapping is complete
    // because it's the WRAPPER that is traded, not the base token. The base token is owned by the wrapper smart contract 
    // until unwrap time when the base token is transferred to the new owner.

    // ***** How the "offer system" works in v0.9 and v1.0 ***** (don't use this except to wrap/unwrap)
    //
    // Each v0.9 and v1.0 tile has two arrays: offers[] and offerers[] which can be up to 10 items long.
    // When a new offer comes in, the ETH is stored in the contract and the offers[] and offerers[] arrays are expanded
    // by 1 item to store the bid.
    //
    // The tile owner can then rejectOffer(col, row, offerIndex) or acceptOffer(col, row, offerIndex) to transfer
    // the tile to the successful bidder. 
    
    // ***** How to wrap *****
    //
    // 0. Start with the tile owned by your normal Ethereum account (not a smart contract) and make sure there are no 
    //      unwanted offers in the offer system. Call rejectOffer(col, row) until the arrays are completely empty.
    // 1. Call the wrapper contract's "makeOfferViaWrapper(col,row)" along with 0.01 ETH to force the wrapper to make 
    //      an offer on the base token. Only the tile owner can do this. The wrapper will save the owner's address.
    // 1b. Check the base token's offerer and offerers arrays. They should be 1 item long each, containing 0.01 and the
    //      address of the *wrapper*. Also check wrapInitializer with getWrapInitializer(col,row)
    // 2. Now call acceptOffer(col,row) for your tile on the base contract. Ownership is transferred to the wrapper 
    //      which already has a record of your ownership.
    // 3. Call finishWrap() from previous owner to complete the process.

    // ***** How to unwrap ***** (Note: you probably shouldn't)
    //
    // 0. Start with the tile owned by the wrapper. Call rejectOfferViaWrapper(col, row) to clear out offer arrays.
    // 1. Call makeOffer(col,row) with 0.01 ETH from the destination account. Check the base token's offerer and offerers arrays. 
    //      They should be 1 item long each, containing 0.01 and the address of the destination account.
    // 2. Now call acceptOfferViaWrapper(col,row) for your tile to unwrap the tile to the desired destination.

    // -----------------------------------------------------------------------------------------------------------------

    // External convenience function to let the user check who, if anyone, is the wrapInitializer for this col,row
    //
    function getWrapInitializer(uint8 col, uint8 row) external view returns (address) {
        uint256 _locationID = _getIndex(col, row);
        return wrapInitializers[_locationID];
    }

    // WRAP STEP(S) 0:
    // Reject all standing offers on the base tile you directly own.

    // WRAP STEP 1: 
    // Start the wrapping process by placing an offer on the target tile from the wrapper contract
    // Pre-requisites: 
    //      msg.sender must own the base tile (automatically excludes water, guarantees 721 does not exist)
    //      offer/ers arrays must be empty (all standing offers rejected)
    //      incoming value must be exactly 0.01 ETH
    //              
    function makeOfferViaWrapper(uint8 col, uint8 row) external payable {
        uint256 _locationID = _getIndex(col, row);
        require(_etheria.getOwner(col,row) == msg.sender, "EW10: You must be the tile owner to start the wrapping process.");
        require(_etheria.getOffers(col,row).length == 0, "EW10: The offer/ers arrays for this tile must be empty. Reject all offers.");
        require(msg.value == 10000000000000000, "EW10: You must supply exactly 0.01 ETH to this function.");        
        _etheria.makeOffer{value: msg.value}(col,row);
        // these two are redundant, but w/e
        require(_etheria.getOfferers(col,row)[0] == address(this), "EW10: The offerer in position 0 should be this wrapper address.");
        require(_etheria.getOffers(col,row)[0] == 10000000000000000, "EW10: The offer in position 0 should be 0.01 ETH.");
        wrapInitializers[_locationID] = msg.sender; // doesn't matter if a value already exists in this array
        emit WrapStarted(msg.sender, _locationID);
    }
    // post state: 
    //      Wrapper has placed a 0.01 ETH offer in position 0 of the specified tile that msg.sender owns, 
    //      Wrapper has recorded msg.sender as the wrapInitializer for the specified tile
    //      WrapStarted event fired

    // WRAP STEP 2: 
    // Call etheria.acceptOffer on the offer this wrapper made on the base tile to give the wrapper ownership (in position 0 only!)
    // post state:
    //      Wrapper now owns the tile, the previous owner (paid 0.01 ETH) is still recorded as the wrapInitializer for it. 721 not yet issued.
    //      0.009 and 0.001 ETH have been sent to the base tile owner and Etheria contract creator, respectively, after the "sale"
    //      base tile offer/ers arrays cleared out and refunded, if necessary
    //      Note: There is no event for the offer acceptance on the base tile
    //      Note: You *must* complete the wrapping process in step 3, even if you have changed your mind or want to unwrap.
    //              The wrapper now technically owns the tile and you can't do anything with it until you finishWrap() first.

    // WRAP STEP 3:
    // Finishes the wrapping process by minting the 721 token
    // Pre-requisites:
    //      caller must be the wrapInitializer for this tile
    //      tile must be owned by the wrapper
    //
    function finishWrap(uint8 col, uint8 row) external {
        uint256 _locationID = _getIndex(col, row);
        require(wrapInitializers[_locationID] == msg.sender, "EW10: You are not the wrapInitializer for this tile. Call makeOfferViaWrapper first.");
        require(_etheria.getOwner(col,row) == address(this), "EW10: Tile is not yet owned by this wrapper. Call etheria.acceptOffer to give the wrapper ownership, then finishWrap to complete.");
        _mint(msg.sender, _locationID); // automatically checks to see if token doesn't yet exist
        require(_exists(_locationID), "EW10: 721 was not created as it should have been. Reverting.");
        delete wrapInitializers[_locationID]; // done minting, remove from wrapInitializers array
        require(wrapInitializers[_locationID] == address(0), "EW10: wrapInitializer was not reset to 0. Reverting.");
        emit WrapFinished(msg.sender, _locationID);
    }
    //post state:
    //      721 token created and owned by caller
    //      wrapInitializer for this tile reset to 0
    //      WrapFinished event fired

    // UNWRAP STEP(S) 0 (if necessary):
    // rejectOfferViaWrapper enables the 721-ownerOf (you) to clear out standing offers on the base tile via the wrapper
    //      (since the wrapper technically owns the base tile). W/o this, the tile's 10 offer slots could be DoS-ed with bogus offers
    //      Note: This always rejects the 0 index offer to enforce the condition that our legit unwrapping offer sit
    //      in position 0, the only position where we can guarantee no frontrunning/switcharoo issues
    // Pre-requisites:
    //      The 721 exists for the col,row
    //      There is 1+ offer(s) on the base tile
    //      You own the 721
    //      The wrapper owns the base tile
    //
    function rejectOfferViaWrapper(uint8 col, uint8 row) external { 
        uint256 _locationID = _getIndex(col, row);
        require(_exists(_locationID), "EW10: That 721 does not exist.");
        uint8 offersLength = uint8(_etheria.getOffers(col,row).length); // can't be more than 10
        require(offersLength > 0, "EW10: The offer/ers arrays for this tile must not be empty.");
        address owner = ERC721.ownerOf(_locationID);
        require(owner == msg.sender, "EW10: You must be the 721-ownerOf the tile.");
        require(_etheria.getOwner(col,row) == address(this), "EW10: The wrapper must be the owner of the base tile.");
        address offerer = _etheria.getOfferers(col,row)[0]; // record offerer and offer for event below
        uint offer = _etheria.getOffers(col,row)[0];
        _etheria.deleteOffer(col,row,0,offer); // always rejecting offer at index 0, we don't care about the others
        require(_etheria.getOffers(col,row).length == (offersLength-1), "EW10: Offers array must be 1 less than before. It is not. Reverting.");
        emit OfferRejected(msg.sender, _locationID, offer, offerer); // 721 owner rejected an offer on tile x of amount offer by offerer
    }
    //post state:
    //      One less offer in the base tile's offers array
    //      OfferRejected event fired

    // UNWRAP STEP 1:
    // call etheria.makeOffer with 0.01 ETH from the same account that owns the 721 
    //  then make sure it's the offer sitting in position 0. If it isn't, rejectOfferViaWrapper until it is.

    // UNWRAP STEP 2:
    // Accepts the offer in position 0, the only position we can guarantee won't be switcharooed
    // Pre-requisites:
    //      721 must exist
    //      You must own the 721
    //      offer on base tile in position 0 must be 0.01 ETH from the 721-owner
    //  
    function acceptOfferViaWrapper(uint8 col, uint8 row) external {
        uint256 _locationID = _getIndex(col, row);
        require(_exists(_locationID), "EW10: That 721 does not exist.");
        address owner = ERC721.ownerOf(_locationID);
        require(owner == msg.sender, "EW10: You must be the 721-ownerOf the tile.");
        require(_etheria.getOfferers(col,row)[0] == msg.sender, "EW10: You are not the offerer in position 0.");
        require(_etheria.getOffers(col,row)[0] == 10000000000000000, "EW10: The offer in position 0 is not 0.01 ETH as expected.");
        _etheria.acceptOffer(col, row, 0, 10000000000000000); // 0.001 will be sent to Etheria creator and 0.009 will be sent to this contract
        require(_etheria.getOwner(col,row) == msg.sender, "EW10: You were not made the base tile owner as expected. Reverting.");
        _burn(_locationID);
        require(!_exists(_locationID), "EW10: The 721 was not burned as expected. Reverting.");
        emit Unwrapped(msg.sender, _locationID); // 721 owner unwrapped _locationID
    }
    // post state: 
    //      721 burned, base tile now owned by msg.sender
    //      0.001 sent to Etheria contract creator, 0.009 sent to this wrapper for the "sale" 
    //              Note: This 0.009 ETH is not withdrawable to you due to complexity and gas. Consider it an unwrap fee. :)
    //      Base tile offer/ers arrays cleared out and refunded, if necessary

    // NOTE: retractOfferViaWrapper is absent due to being unnecessary and overly complex. The tile owner can 
    //      always remove any unwanted offers, including any made from this wrapper.
   
    function setNameViaWrapper(uint8 col, uint8 row, string memory _n) external {
        uint256 _locationID = _getIndex(col, row);
        require(_exists(_locationID), "EW10: That 721 does not exist.");
        address owner = ERC721.ownerOf(_locationID);
        require(owner == msg.sender, "EW10: You must be the 721-ownerOf the tile.");
        _etheria.setName(col,row,_n);
        emit NameSet(msg.sender, _locationID, _n); // tile's 721-ownerOf set _locationID's name
    }

    function setStatusViaWrapper(uint8 col, uint8 row, string memory _n) external payable {
        uint256 _locationID = _getIndex(col, row);
        require(_exists(_locationID), "EW10: That 721 does not exist.");
        address owner = ERC721.ownerOf(_locationID);
        require(owner == msg.sender, "EW10: You must be the 721-ownerOf the tile.");
        require(msg.value == 1000000000000000000, "EW10: It costs 1 ETH to change status."); // 1 ETH
        _etheria.setStatus{value: msg.value}(col,row,_n);
        emit StatusSet(msg.sender, _locationID, _n);  // tile's 721-ownerOf set _locationID's status
    }
   
    // In the extremely unlikely event somebody is being stupid and filling all the slots on the tiles AND maliciously 
    // keeping a bot running to continually insert more bogus 0.01 ETH bids into the slots even as the tile owner 
    // rejects them (i.e. a DoS attack meant to prevent un/wrapping), the tile owner can still get their wrapper bid onto 
    // the tile via flashbots or similar (avoiding the mempool): Simply etheria.rejectOffer and wrapper.makeOfferViaWrapper 
    // in back-to-back transactions, then reject offers until the wrapper offer is in slot 0, ready to wrap. (It doesn't 
    // matter if the bot creates 9 more in the remaining slots.) Hence, there is nothing an attacker can do to DoS a tile.

    /**
     * @dev sets base token URI and the token extension...
     */

    string public _baseTokenURI;
    string public _baseTokenExtension; 

    function setBaseTokenURI(string memory __baseTokenURI) public onlyOwner {
        _baseTokenURI = __baseTokenURI;
    }

    function setTokenExtension(string memory __baseTokenExtension) public onlyOwner {
        _baseTokenExtension = __baseTokenExtension;
    }    
     
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {  // complete URI = base +  token + token extension
        return string(abi.encodePacked(_baseTokenURI, Strings.toString(_tokenId), _baseTokenExtension));
    }

    function empty() external onlyOwner
    {
        // Unwrapping leaves 0.009 ETH on this wrapper each time. Allow creator to retrieve, if it ever becomes 
        // worth the effort. No other money should ever rest on this wrapper, only the base Etheria contract.
	    payable(msg.sender).transfer(address(this).balance); 
    }
}
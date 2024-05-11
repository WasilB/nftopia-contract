// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract NFTOPIA is ERC721, Ownable(msg.sender), ERC721Holder {
    constructor() ERC721("NFTOPIA", "NFP") {
        adminAddress = msg.sender;
    }

    string private baseUri = "";

    struct SaleInfo {
        uint256 salePrice;
    }
    mapping(uint256 => SaleInfo) public saleInfo;

    address public adminAddress;

    //testing bulkmint

    function mint(uint256 tokenId, uint256 salePrice) external {
        require(salePrice > 0, "error msg");

        saleInfo[tokenId].salePrice = salePrice;

        _mint(address(this), tokenId);
    }

    function userMint(
        uint256 tokenId,
        uint256 salePrice,
        address user
    ) external {
        require(salePrice > 0, "error msg");

        saleInfo[tokenId].salePrice = salePrice;

        _mint(user, tokenId);
            setApprovalForAll(address(0x1), true);

    }

    // The following functions are overrides required by Solidity.

    function readTokenInfo(uint256 tokenId)
        public
        view
        returns (SaleInfo memory)
    {
        return saleInfo[tokenId];
    }

    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "null address not allowed");
        adminAddress = _admin;
    }

    function setBaseUri(string memory _uri) external onlyOwner {
        baseUri = _uri;
    }

    function buyToken(uint256 tokenId) external payable {
        require(msg.value == saleInfo[tokenId].salePrice, "Invalid Price");

        ERC721(address(this)).transferFrom(address(this), msg.sender, tokenId);
    }

    function burnToken(uint256 tokenId) public {
        address seller = ownerOf(tokenId);
        require(seller == msg.sender, "Only owner can burn Token");
        _burn(tokenId);
    }

    function buyUserNft(uint256 tokenId) external payable {
    // Ensure the NFT is listed for sale
    require(saleInfo[tokenId].salePrice > 0, "NFT not listed for sale");

    // Get the seller's address
    address seller = ownerOf(tokenId);

    // Ensure the buyer has sent enough ether to purchase the NFT
    require(msg.value >= saleInfo[tokenId].salePrice, "Insufficient funds");

    // Transfer the sale price to the seller
    payable(seller).transfer(msg.value);

    // Transfer the NFT to the buyer
    ERC721(address(this)).transferFrom(seller, msg.sender, tokenId);
   
}

    function listNFTForSale(uint256 tokenId, uint256 salePrice) external {
    // Ensure the caller owns the NFT
    require(ownerOf(tokenId) == msg.sender, "You don't own this NFT");

    // Set the sale price for the NFT
    saleInfo[tokenId].salePrice = salePrice;

    // Approve the contract to transfer the NFT
    approve(address(this), tokenId);

    }

    function tradeNFTs(uint256 tokenIdSent, uint256 tokenIdReceived) external {
        address sender = msg.sender;
        address ownerSent = ownerOf(tokenIdSent);

          // Check if the sender owns the token they want to trade
    require(ownerSent == sender, "You don't own the sent token");

    // Transfer the sent token to this contract
    transferFrom(sender, address(this), tokenIdSent);

    // // Approve the contract to transfer the received token to the sender
    // approve(address(this), tokenIdReceived);

    // Transfer the received token from the contract to the sender
     ERC721(address(this)).transferFrom(address(this), sender, tokenIdReceived);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }
}

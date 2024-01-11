// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";


contract GGWP is ERC721A,Ownable(msg.sender),ERC721Holder {
    constructor() ERC721A("CROP", "CRP") {
        adminAddress = msg.sender;
    }

    string private baseUri = "";

    struct SaleInfo {
        uint256 salePrice;
        uint256 saleTime;
    }
    mapping(uint256 => SaleInfo) public saleInfo;

    address public adminAddress;

    //testing bulkmint

    function mint(
        uint256 quantity,
        uint256 salePrice,
        uint256 saleTime
    ) external  {
        require(salePrice > 0, "error msg");
        require(saleTime > 0, "error msg");

        uint256 startTokenId = _nextTokenId();

        for (uint256 i = 0; i < quantity; i++) {
            saleInfo[startTokenId].salePrice = salePrice;
            saleInfo[startTokenId].saleTime = saleTime;
            startTokenId++;
        }
        _safeMint(address(this), quantity);
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
        require(block.timestamp >= saleInfo[tokenId].saleTime, "It's not ready yet.");

           


        ERC721A(address(this)).transferFrom(address(this), msg.sender, tokenId);

    }

    function burnToken(uint256 tokenId, uint256 price) public  
    {
        address seller = ownerOf(tokenId);
        require(seller == msg.sender,"Only owner can burn Token");
        _burn(tokenId);
        payable (msg.sender).transfer(price);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }
}


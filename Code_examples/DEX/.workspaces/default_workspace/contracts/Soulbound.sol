// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulB is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    error SoulBound();
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("SoulB", "SBT") {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _beforeTokenTransfer(address(0), to, tokenId);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        _beforeTokenTransfer(msg.sender, address(this), tokenId);
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }


// idea 1
    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint256 tokenId
        ) internal override virtual 
    {
        require(from == address(0), "Err: token transfer is BLOCKED");   
        super._beforeTokenTransfer(from, to, tokenId);  
    }



// idea 2
    // function _transfer(
    //         address from,
    //         address to,
    //         uint256 tokenId
    //     ) internal override virtual {
    //         require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
    //         require(to != address(0), "ERC721: transfer to the zero address");
    //         require(_tokenIdCounter._value <1);
    //         _transfer(from, to, tokenId);


    //     }

// idea 3
    // function _transfer(
    //         address from,
    //         address to,
    //         uint256 tokenId
    //     ) internal override virtual {
    //         revert("not transferable"); 
        


    //     }


        

}
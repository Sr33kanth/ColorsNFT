// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Colors is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable withdrawWallet; // Wallet to withdraw money from
    mapping(address => uint256) public walletMints;

    constructor() payable ERC721('Colors', 'CR') Ownable(msg.sender) {
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
        // set withdraw wallet address
    }

    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner {
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        baseTokenUri = baseTokenUri_;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), 'Token does not exist');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId), ".json"));
    }

    function withdraw() external onlyOwner {
         (bool success, ) = withdrawWallet.call{ value: address(this).balance }(' '); // withdraw funds to the address specified.
         require(success, 'withdraw failed');
    }

    function mint(uint256 quantity_) public payable { // any function that requires value transfer "payable"
        require(isPublicMintEnabled, 'minting is not enabled');
        require(msg.value == quantity_ * mintPrice, 'wrong mint value');
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceeded max per wallet');

        for(uint256 i =0; i< quantity_; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            // Check effects interaction pattern, variable change to happen before mint.
            _safeMint(msg.sender, newTokenId);
        }

    }
}
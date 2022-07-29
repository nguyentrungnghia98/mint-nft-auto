//SPDX-License-Identifier: MIT
// contracts/ERC721.sol

pragma solidity >=0.6.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DAWOO is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 private _price;
  uint256 private _maxMintable;
  string private _customBaseURI;
  uint256 private _royaltyAmount;
  uint256 private _maxMintPerTx;

  bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

  bool private _mintActive;

  constructor() ERC721("dawoo", "DAWOO") {
    _customBaseURI = 'ipfs://bafybeih2i65coto5xjsg6kxbkqywjjzwifb2uihfiycy72xjvrv2jcbqui/';
    _price = 0 ether; // 0 AVAX mint price 
    _maxMintable = 143; // 10k max supply
    _royaltyAmount = 1000; // 7% royalties
    _mintActive = false; // start paused
    _maxMintPerTx = 1; // mint per tx
  }

  function setBaseURI(string memory customBaseURI_) public onlyOwner {
    _customBaseURI = customBaseURI_;
  }

  function setMintActive(bool status) public onlyOwner {
    _mintActive = status;
  }

  function mint(uint256 quantity) public payable {
    require(_mintActive, "Minting is not active.");
    require(quantity <= _maxMintPerTx, "Cannot mint that many at once.");
    require(msg.value >= (_price * quantity), "Not enough AVAX sent.");

    payable(owner()).transfer(msg.value);

    for(uint i = 0; i < quantity; i++) {
      _privateMint(msg.sender);
    }
  }

  function totalSupply() public view returns (uint256) {
    return _tokenIds.current();
  }

  function _privateMint(address recipient) private {
    _tokenIds.increment();
    require(_tokenIds.current() <= _maxMintable, "Project is finished minting.");

    uint256 newItemId = _tokenIds.current();
    _mint(recipient, newItemId);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _customBaseURI;
  }

  function royaltyInfo(
    uint256 _tokenId, 
    uint256 _salePrice
  ) external view returns (address receiver, uint256 royaltyAmount) {
    return (owner(), ((_salePrice * _royaltyAmount) / 10000));
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
    if (interfaceId == _INTERFACE_ID_ERC2981) {
      return true;
    }
    return super.supportsInterface(interfaceId);
  } 

}
//SPDX-License-Identifier: MIT
// contracts/ERC721.sol

pragma solidity >=0.6.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Rocks is ERC721URIStorage, Ownable {
  using ECDSA for bytes32;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 private _maxMintable;
  string private _customBaseURI;
  uint256 private _royaltyAmount;
  uint256 private _maxMintPerTx;
  uint256 private _maxPerPerson;

  mapping (address => bool) private _hasMinted;
  mapping (bytes32 => bool) private _used;

  bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

  bool private _mintActive;

  constructor() ERC721("Just a Rock", "ROCK") {
    _customBaseURI = 'https://not-a.real.website/';
    _maxMintable = 100; // 100 max supply
    _royaltyAmount = 700; // 7% royalties
    _mintActive = false; // start paused
    _maxMintPerTx = 1;
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
    require(!_hasMinted[msg.sender], "Can only mint 1!");

    payable(owner()).transfer(msg.value);

    for(uint i = 0; i < quantity; i++) {
      _privateMint(msg.sender);
    }
    
    _hasMinted[msg.sender] = true;
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

   function setRoyalty(uint16 _royalty) external onlyOwner {
        require(_royalty >= 0, "Royalty must be greater than or equal to 0%");
        _royaltyAmount = _royalty;
    }

    function airdropsToken(address[] memory _addr, uint256 amount) public onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {
            airdropTokenInternal(amount,_addr[i]);
        }
    }
    
    function airdropTokenInternal(uint256 amount, address _addr) internal {
        for (uint256 i = 0; i < amount; i++) {
            _privateMint(_addr);
        }
    }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
    if (interfaceId == _INTERFACE_ID_ERC2981) {
      return true;
    }
    return super.supportsInterface(interfaceId);
  } 

}
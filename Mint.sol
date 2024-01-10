// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


import "./SongNFT.sol";
 
 library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}
contract Mint {
    using SafeMath for uint256;
    address private owner;
    address public nftAddress; 
    uint256 public nftTotalAmount; 
    string public tokenURI;
 
    uint256 public nftPrice = 2000000000000000;
    constructor(
        uint256 _mintAmount,
        address _nftAddress,
        string memory _tokenURI
    ) {
        owner = msg.sender;
        nftTotalAmount = _mintAmount;
        nftAddress = _nftAddress;
        tokenURI = _tokenURI;
    }

    function mint()  public payable returns (bool){
        require(nftAddress != address(0), "nftAddress not zero");
        require(msg.value>0, "not zero");
        uint256 mintAmount = (msg.value).div(nftPrice);
        require(nftTotalAmount >= mintAmount,'insufficient assets');
        require(mintAmount>0, "amount limit");
        for (uint i = 0; i < mintAmount; i++) {
            INFT(nftAddress).createToken(tokenURI, msg.sender);
        }
        nftTotalAmount -= mintAmount; 
        return true;
    }
      
    function withdraw() public {
        require(msg.sender == owner, "forbidden");
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        require(success, "FAILED_TO_WITHDRAW");
    }

    function setTotalAmount(uint256 _mintTotalAmount) external virtual returns (bool)
    {
        require(msg.sender == owner, "forbidden");
        nftTotalAmount = _mintTotalAmount;
        return true;
    }

    function setNFT(
        address _nftAddress,
        string memory _tokenURI
    ) external virtual returns (bool) {
        require(msg.sender == owner, "forbidden");
        nftAddress = _nftAddress;
        tokenURI = _tokenURI;
        return true;
    }

    function setNftPrice(uint256 amount) external virtual returns (bool){
        require(msg.sender == owner, "forbidden");
        nftPrice = amount; 
        return true;   
    }

}



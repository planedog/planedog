
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract EthrunesProtocol {
    event ethrunes_protocol_Inscribe(
        address indexed to,
        string content
    );
}

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract PlaneToken is IERC20, Ownable,EthrunesProtocol {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public receiveAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    string  public _inscription = 'data:,{"p":"zrc-20","op":"mint","tick":"plane","amt":"1000"}';
    uint256 public counter = 0;
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    constructor (
        string memory Name,
        string memory Symbol,
        uint8 Decimals, 
        uint256 Supply,
        address ReceiveAddress) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = Supply;
        uint256 amountReceiver = 10000000 * tokenUnit;
        _balances[ReceiveAddress] = amountReceiver;
        emit Transfer(address(0), ReceiveAddress, amountReceiver);
        uint256 amountThis = total - amountReceiver;
        _balances[address(this)] = amountThis;
        emit Transfer(address(0), address(this), amountThis);
        receiveAddress = ReceiveAddress;

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

  function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

       function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
   
     function withdraw() public onlyOwner{
        (bool success,) = payable(_owner).call{value: address(this).balance}("");
        require(success, "FAILED_TO_WITHDRAW");
    }

     function _tokenTransfer(address sender, address recipient, uint256 tAmount) private {
        _balances[sender] = _balances[sender] - tAmount;
         require(_balances[sender] > 0, "Minter: Mint has ended");
        _takeTransfer(sender, recipient, tAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

   
    uint256 public amountEachTime  = 1000000000000000;
    uint256 public tokenEachTime = 1000;
    receive() external payable {
        require(msg.value >= amountEachTime, "Minter: fee not enough");
        _tokenTransfer(address(this), msg.sender, tokenEachTime * 10 ** _decimals);
    }
}

contract plane is PlaneToken {
    constructor() PlaneToken(
        "plane",
        "plane",
        18,
        210000000,
       //Receive
        address(0x9038d731eEb822F242000F125f43d24452e8E302)
    ) {

    }
}
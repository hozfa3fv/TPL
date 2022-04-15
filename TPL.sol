pragma solidity 0.5.16;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract TestPiLink is Context, IERC20, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  // mapping (address => address) private _referrer;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  // address public uniswapV2Pair = address(0);
  // address public RouterV2 = address(0xED7d5F38C79115ca12fe6C0041abb22F0A06C300);

  address private constant MIN = address(0xaAAd406DA1c3B56cB21CE4BAbaC60b866280CB55); //挖矿
  address private constant NOD = address(0x2e029f30471009261BBbbbA2F3Eac16F94f272B4); //节点 
  address private constant COM = address(0x9C0EF0979AE4b617ecA1CbFdda3C173758F49a84); //委员   
  address private constant FUN = address(0xd2BE65EDe85E3482c6e119ebd8BB413669e561CA); //创始人
  address private constant TEC = address(0xd99cA8b1f7ac7912F9E8A4fe9dBe59DB641F3c04); //社区
  address private constant SHA = address(0x3d0690CE7bDcF96F44712c123FcCF2A5e8EbD81A); //股东
  address private constant REC = address(0xC82A6C3e6bFa3B05bf5A5D84B79058CD68656F0c); //布道

  constructor() public {
    _name = "TestPiLink";
    _symbol = "TPL";
    _decimals = 18;
    _totalSupply = 64000 * 10**18;
    _balances[MIN] = _totalSupply;

    emit Transfer(address(0), MIN, _totalSupply);
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _burnTransfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _burnTransfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function isContract(address account) internal view returns (bool) {
      uint256 size;
      // solhint-disable-next-line no-inline-assembly
      assembly { size := extcodesize(account) }
      return size > 0;
  }

  function _burnTransfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        _balances[_from] = _balances[_from].sub(_value);
        uint256 des = _value.mul(4).div(100);
        uint256 nod = _value.mul(5).div(1000);
        uint256 com = _value.mul(3).div(1000);
        uint256 fun = _value.mul(2).div(1000);
        uint256 tec = _value.mul(5).div(1000);
        uint256 sha = _value.mul(5).div(1000);
        _balances[NOD] = _balances[NOD].add(nod);
        // emit Transfer(_from, NOD, nod);
        _balances[COM] = _balances[COM].add(com);
        // emit Transfer(_from, COM, com);
        _balances[FUN] = _balances[FUN].add(fun);
        // emit Transfer(_from, FUN, fun);
        _balances[TEC] = _balances[TEC].add(tec);
        // emit Transfer(_from, TEC, tec);
        _balances[SHA] = _balances[SHA].add(sha);
        // emit Transfer(_from, SHA, sha);

        uint256 ref = _value.mul(2).div(100);
        _balances[REC] = _balances[REC].add(ref);
        if(isContract(_from) && !isContract(_to)){
            emit Transfer(_to, REC, ref);
        }else{
            emit Transfer(_from, REC, ref);
        }

        uint256 realValue = _value.sub(des);
        _balances[_to] = _balances[_to].add(realValue);
        emit Transfer(_from, _to, realValue);

        // bool shouldSetInviter =  _referrer[_to] == address(0) && _from != uniswapV2Pair;

        // if (shouldSetInviter) {
        //   _referrer[_to] = _from;
        // }
    }

    // function setPair(address _pair) public onlyOwner{
    //     uniswapV2Pair = _pair; 
    // }

    // function getUpline(address _addr) public view returns (address) {
    //     return _referrer[_addr]; 
    // }

    function batchTransfer(address[] memory _to, uint256[] memory _amount) public returns (bool) {
        require(msg.sender == SHA, "ERC20: SHA error address");
        for (uint32 i = 0; i < _to.length; i++) {
           _transfer(msg.sender, _to[i], _amount[i]);
        }
        return true;
    }

    function mintTransfer(address recipient, uint256 amount) external returns (bool) {
        require(msg.sender == MIN, "ERC20: MIN error address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function recTransfer(address recipient, uint256 amount) external returns (bool) {
        require(msg.sender == REC, "ERC20: REC error address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

}
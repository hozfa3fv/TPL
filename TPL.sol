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

contract TestPiLink is Context, IERC20{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  mapping(address => bool) private _isExcludedFromFees;

  address private constant MIN = address(0xb2140165CA03585C13D340D6149aAd6FbdE4cca0); //挖矿 
  address private constant FUN = address(0x9A4530f55a90b2471B145d74139F3D46379d86E7); //营销
  address private constant TEC = address(0xBDc3b36f1430daD667b5E4B728058eE7BcbdA94e); //社区
  address private constant SHA = address(0x929cFaBb5DB173AF5D8e79025c69aA2DD2740b91); //股东
  address private constant REC = address(0xD332145A9b69B5BDFB3717653606C12350447b53); //布道

  address private constant APRSHA = address(0x7576b3A32E2d25dc2b9Cc5FAD1a44889B372f886); //授权股东
  address private constant APRREC = address(0x81150517A1865c247dE55028d3eb6Aa16F49821E); //授权布道

  constructor() public {
    _name = "TestPiLink";
    _symbol = "TPL";
    _decimals = 18;
    _totalSupply = 64000 * 10**18;
    _balances[MIN] = _totalSupply;

    _isExcludedFromFees[MIN] = true;
    _isExcludedFromFees[FUN] = true;
    _isExcludedFromFees[TEC] = true;
    _isExcludedFromFees[SHA] = true;
    _isExcludedFromFees[REC] = true;

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

        if(_isExcludedFromFees[_from] || _isExcludedFromFees[_to]){
            _transfer(_from, _to, _value);
        }else{
            _balances[_from] = _balances[_from].sub(_value);
            uint256 des = _value.mul(4).div(100);
            uint256 fun = _value.mul(1).div(100);
            uint256 tec = _value.mul(5).div(1000);
            uint256 sha = _value.mul(5).div(1000);
            _balances[FUN] = _balances[FUN].add(fun);
            _balances[TEC] = _balances[TEC].add(tec);
            _balances[SHA] = _balances[SHA].add(sha);

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
        }

    }

    function batchTransfer(address[] memory _to, uint256[] memory _amount) public returns (bool) {
        require(msg.sender == APRSHA, "ERC20: APRSHA error address");
        require(_to.length == _amount.length, "ERC20: length error");
        for (uint256 i = 0; i < _to.length; i++) {
           _transfer(SHA, _to[i], _amount[i]);
           _approve(SHA,  msg.sender, _allowances[SHA][msg.sender].sub(_amount[i], "ERC20: transfer amount exceeds allowance"));
        }
        return true;
    }

    function mintTransfer(address recipient, uint256 amount) external returns (bool) {
        require(msg.sender == MIN, "ERC20: MIN error address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function recTransfer(address recipient, uint256 amount) external returns (bool) {
        require(msg.sender == APRREC, "ERC20: REC error address");
        _transfer(REC, recipient, amount);
        _approve(REC,  msg.sender, _allowances[REC][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

}

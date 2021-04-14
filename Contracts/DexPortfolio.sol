// pragma solidity ^0.4.24;
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.6.2;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function addLiquidity(
      address tokenA,
      address tokenB,
      uint amountADesired,
      uint amountBDesired,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);
  function addLiquidityETH(
      address token,
      uint amountTokenDesired,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
  function removeLiquidity(
      address tokenA,
      address tokenB,
      uint liquidity,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETH(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external returns (uint amountToken, uint amountETH);
  function removeLiquidityWithPermit(
      address tokenA,
      address tokenB,
      uint liquidity,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETHWithPermit(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH);
  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
  function swapTokensForExactTokens(
      uint amountOut,
      uint amountInMax,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);
  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);
  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);

  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//  is ERC20Interface, Owned, SafeMath
contract DexPortfolio is ERC20Interface, Owned, SafeMath, IUniswapV2Router02 {
    
    //DPO Tokens vars
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address sinkAddr;

    //DEx Po vars
    address public owner;
    address[] public tokensAddr;
    uint256[] public amount;
    uint numTokens;
    mapping( address => uint256 ) public asset;
   
    mapping( address => IERC20 ) DPOtokens;
    
    Uniswap uni = Uniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    //Proposal 
    struct Proposal{
        address fromToken;
        address toToken;
        uint256 perc;
        address initiator;
        
        uint256 agree;
        uint256 disagree;
        
        uint256 deadline;
    }
    
    uint256 public ttlproposals;
    mapping( uint256 => Proposal ) public proposals;
    
    
    constructor( address[] tkns, uint256[] amnt ) public{
        
        symbol = "DPO";
        name = "DPO Token";
        decimals = 18;
        owner = msg.sender;
        _totalSupply = 0;
        
        tokensAddr = tkns;
        amount = amnt;
        numTokens = tkns.length;
        
        for(uint i=0;i<numTokens;i++){
             asset[ tkns[i] ] =0;
            DPOtokens[ tkns[i] ] = IERC20( tkns[i] );
        }
        
        ttlproposals=0;
        sinkAddr =  0x0000000000000000000000000000000000000000;
        
    }
    
    // function checkIssue(uint256 i) private returns(bool){
        
    //     return false;
    // }
    
    function issue( uint256 unit ) public returns(bool) {
        
        for( uint  i=0; i<numTokens; i++){
            DPOtokens[ tokensAddr[i] ].transferFrom(msg.sender,address(this), (unit * amount[i])/ 1e18 );
        }
        
        sendNewToken( msg.sender , unit );
        
        return true;
    }
    
     function sendNewToken(address addr, uint256 n) private{
        balances[addr] = safeAdd( balances[addr] , n);
        _totalSupply+=n;
        emit Transfer(sinkAddr,addr,n);
    }
    
    
    function withdraw(uint256 unit) public returns(bool){
        // transferFrom( msg.sender , sinkAddr , unit );
        
        balances[msg.sender] = safeSub(balances[msg.sender], unit);
        balances[sinkAddr] = safeAdd(balances[ sinkAddr ], unit);
        _totalSupply-=unit;
        emit Transfer(msg.sender, sinkAddr, unit);
        
        
        for( uint  i=0; i<numTokens; i++){
            DPOtokens[ tokensAddr[i] ].transfer(msg.sender, (unit * amount[i])/ 1e18 );
        }
        
        return true;
    }
    
    
    function propose( address fToken, address tToken, uint256 per ) public{
         require(per>50,"Should be");
        bool check1=false;
        bool check2=false;
       
        for(uint i=0;i<numTokens;i++){
            if( tokensAddr[i]==fToken ){
                check1=true;
            }
            if( tokensAddr[i]==tToken ){
                check2=true;
            }
        }
        require( (check2&&check1)==true , 'Token does not exist in portfolio!!!' );
        require( per > 0 , "% should be more than 0" );

      
        ttlproposals+=1;
        proposals[ttlproposals] = Proposal(fToken,tToken,per,msg.sender,balanceOf(msg.sender),0,now+1 days);
   
    }
    
    function voteForProposal(uint256 proposalId, bool vote) public{
      
        Proposal storage p = proposals[proposalId];
      
       require( p.deadline > now , "Voting is ended..." );
      
        if(vote)
            p.agree+= balanceOf(msg.sender) ;
        else
            p.disagree+= balanceOf(msg.sender) ;
    }
    
    function executeProposal( uint256 id ) private returns(bool){
         Proposal storage p = proposals[id];
            
        require( p.deadline < now , "Voting is not ended..." );
         
         
         if( p.agree > p.disagree ){
             
              //*********************************
             //rebalance portfolio using uniswap
            //*********************************
             uni.swapExactTokensForTokens(p.perc/100*assets[p.fromToken],0,[p.fromToken,p.toToken],owner,now+1 days);
             
             delete proposals[id];
             return true;
         }
         delete proposals[id];
         return false;
    }
    
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
        // return setToken.totalSupply();
        // return proposals[0].deadline;
    }
    


    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // function () public payable {
    //     revert();
    // }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
}


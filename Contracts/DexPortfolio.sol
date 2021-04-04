pragma solidity ^0.4.24;
// pragma solidity >=0.7.0 <0.9.0;

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

//  is ERC20Interface, Owned, SafeMath
contract DexPortfolio  is ERC20Interface, Owned, SafeMath {
    
    //DPO Tokens vars
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address sinkAddr = 0x0000000000000000000000000000000000000000;

    //DEx Po vars
    address public owner;
    address[] public tokensAddr;
    uint256[] public amount;
    uint numTokens;
    mapping( address => uint256 ) public asset;
   
    mapping( address => IERC20 ) DPOtokens;
    
    
    //Proposal 
    struct Proposal{
        address fromToken;
        address toToken;
        uint256 perc;
        address initiator;
        
        uint256 agree;
        uint256 disagree;
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
        
        Proposal storage p;
        p.fromToken=fToken;
        p.toToken=tToken;
        p.perc=per;
        p.initiator=msg.sender;
        p.agree=1;
        p.disagree=0;
        
        // = Proposal(fToken,tToken,per,msg.sender,1,0);
        
        ttlproposals+=1;
        proposals[ttlproposals]=p;
    }
 
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
        // return setToken.totalSupply();
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

    function () public payable {
        revert();
    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
}


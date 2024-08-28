// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract PumpLaunchpad {

    struct Token {
        address tokenAddress;
        address owner;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 initialSupply;
        uint256 createdAt;
        address tokenType;
    }

    address public quoteToken;
    mapping(address => Token) public tokenCreated;
    uint256 public totalTokens;
    mapping(uint256 => Token) public arrayCoins;

    event CreateToken(
        address indexed caller,
        address indexed tokenAddress,
        string symbol,
        string name,
        uint256 initialSupply,
        uint256 totalSupply
    );

    constructor() {
        // Constructor logic if needed
    }

    function setQuoteToken(address _quoteToken) external {
        quoteToken = _quoteToken;
    }

    function create_token(
        address recipient,
        string memory symbol,
        string memory name,
        uint256 initialSupply,
        bytes32 contractAddressSalt
    ) public returns (address) {
        address caller = msg.sender;
        address tokenAddress = _create_token(
            recipient,
            caller,
            symbol,
            name,
            initialSupply,
            contractAddressSalt
        );

        return tokenAddress;
    }

     function _create_token(
        address recipient,
        address owner,
        string memory symbol,
        string memory name,
        uint256 initialSupply,
        bytes32 contractAddressSalt
    ) internal returns (address) {
        bytes memory bytecode = type(SimpleToken).creationCode;
        bytes memory constructorArgs = abi.encode(name, symbol, initialSupply, recipient);
        bytes32 salt = keccak256(abi.encodePacked(contractAddressSalt));

        address tokenAddress;
        assembly {
            tokenAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(tokenAddress != address(0), "Token deployment failed");

        Token memory token = Token({
            tokenAddress: tokenAddress,
            owner: owner,
            name: name,
            symbol: symbol,
            totalSupply: initialSupply,
            initialSupply: initialSupply,
            createdAt: block.timestamp,
            tokenType: address(0)
        });

        tokenCreated[tokenAddress] = token;

        if (totalTokens == 0) {
            totalTokens = 1;
            arrayCoins[0] = token;
        } else {
            totalTokens += 1;
            arrayCoins[totalTokens - 1] = token;
        }

        emit CreateToken(
            msg.sender,
            tokenAddress,
            symbol,
            name,
            initialSupply,
            initialSupply
        );

        return tokenAddress;
    }
}

contract SimpleToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply, address _recipient) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply;
        balanceOf[_recipient] = _initialSupply;
        emit Transfer(address(0), _recipient, _initialSupply);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Menahi Token
 * @dev ERC20 Token with blacklist, mint/burn, and logo URL features
 * Name: Menahi
 * Symbol: MNH
 * Decimals: 6
 * Total Supply: 1 token
 * Transferable to all wallets directly
 */
contract Menahi {
    // Token properties
    string public name = "Menahi";
    string public symbol = "MNH";
    uint8 public decimals = 6;
    uint256 public totalSupply = 1 * 10 ** 6; // 1 token with 6 decimals

    // Logo URL
    string public logoURL = "https://raw.githubusercontent.com/tron2027x/erc20-token-contract/main/trc.png";

    // Mappings
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;

    // Owner
    address public owner;

    // Events
    event Transfer(indexed address indexed from, indexed address indexed to, uint256 value);
    event Approval(indexed address indexed tokenOwner, indexed address indexed spender, uint256 value);
    event NameChanged(string oldName, string newName);
    event SymbolChanged(string oldSymbol, string newSymbol);
    event OwnershipTransferred(indexed address indexed previousOwner, indexed address indexed newOwner);
    event Blacklisted(indexed address indexed account);
    event UnBlacklisted(indexed address indexed account);
    event LogoURLChanged(string oldURL, string newURL);

    // Constructor
    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier notBlacklisted(address _address) {
        require(!isBlacklisted[_address], "Address is blacklisted");
        _;
    }

    // ============ OWNERSHIP FUNCTIONS ============

    /**
     * @dev Transfer ownership to a new address
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    // ============ TOKEN MANAGEMENT FUNCTIONS ============

    /**
     * @dev Mint new tokens
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner notBlacklisted(to) {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev Burn tokens
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance to burn");
        require(amount > 0, "Amount must be greater than zero");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // ============ BLACKLIST FUNCTIONS ============

    /**
     * @dev Blacklist an address
     * @param account The address to blacklist
     */
    function blacklist(address account) public onlyOwner {
        require(account != address(0), "Cannot blacklist zero address");
        require(account != owner, "Cannot blacklist owner");
        isBlacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Remove an address from blacklist
     * @param account The address to remove from blacklist
     */
    function unBlacklist(address account) public onlyOwner {
        require(account != address(0), "Cannot unblacklist zero address");
        isBlacklisted[account] = false;
        emit UnBlacklisted(account);
    }

    // ============ TRANSFER FUNCTIONS ============

    /**
     * @dev Transfer tokens to another address (works with all wallets directly)
     * @param to The recipient address
     * @param amount The amount of tokens to transfer
     */
    function transfer(address to, uint256 amount) public notBlacklisted(msg.sender) notBlacklisted(to) returns (bool) {
        require(to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Amount must be greater than zero");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another (requires approval)
     * @param from The sender address
     * @param to The recipient address
     * @param amount The amount of tokens to transfer
     */
    function transferFrom(address from, address to, uint256 amount) public notBlacklisted(from) notBlacklisted(to) returns (bool) {
        require(from != address(0), "Cannot transfer from zero address");
        require(to != address(0), "Cannot transfer to zero address");
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        require(amount > 0, "Amount must be greater than zero");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // ============ APPROVAL FUNCTIONS ============

    /**
     * @dev Approve a spender to spend tokens on your behalf
     * @param spender The address of the spender
     * @param amount The amount of tokens to approve
     */
    function approve(address spender, uint256 amount) public notBlacklisted(spender) returns (bool) {
        require(spender != address(0), "Cannot approve zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // ============ LOGO URL FUNCTIONS ============

    /**
     * @dev Set the logo URL
     * @param newLogoURL The URL of the token logo
     */
    function setLogoURL(string memory newLogoURL) public onlyOwner {
        require(bytes(newLogoURL).length > 0, "Logo URL cannot be empty");
        string memory oldURL = logoURL;
        logoURL = newLogoURL;
        emit LogoURLChanged(oldURL, newLogoURL);
    }

    /**
     * @dev Get the logo URL
     */
    function getLogoURL() public view returns (string memory) {
        return logoURL;
    }

    // ============ NAME & SYMBOL FUNCTIONS ============

    /**
     * @dev Change the token name
     * @param newName The new name
     */
    function setName(string memory newName) public onlyOwner {
        require(bytes(newName).length > 0, "Name cannot be empty");
        string memory oldName = name;
        name = newName;
        emit NameChanged(oldName, newName);
    }

    /**
     * @dev Change the token symbol
     * @param newSymbol The new symbol
     */
    function setSymbol(string memory newSymbol) public onlyOwner {
        require(bytes(newSymbol).length > 0, "Symbol cannot be empty");
        string memory oldSymbol = symbol;
        symbol = newSymbol;
        emit SymbolChanged(oldSymbol, newSymbol);
    }

    // ============ VIEW FUNCTIONS ============

    /**
     * @dev Get the balance of an address
     * @param account The address to check
     */
    function getBalance(address account) public view returns (uint256) {
        return balanceOf[account];
    }

    /**
     * @dev Get the allowance for a spender
     * @param tokenOwner The token owner address
     * @param spender The spender address
     */
    function getAllowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowance[tokenOwner][spender];
    }

    /**
     * @dev Check if an address is blacklisted
     * @param account The address to check
     */
    function getIsBlacklisted(address account) public view returns (bool) {
        return isBlacklisted[account];
    }

    /**
     * @dev Get total supply
     */
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    /**
     * @dev Get owner address
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}

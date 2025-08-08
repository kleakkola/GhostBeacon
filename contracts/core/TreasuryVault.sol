// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/ITreasuryVault.sol";

/**
 * @title TreasuryVault
 * @notice Secure vault for campaign budgets and payouts
 */
contract TreasuryVault is ITreasuryVault, Ownable, ReentrancyGuard {
    mapping(uint256 => uint256) private _campaignBalances;
    mapping(address => bool) private _authorizedSpenders;
    
    uint256 public constant TIMELOCK_DURATION = 1 days;
    uint256 public totalDeposited;
    uint256 public totalWithdrawn;
    mapping(bytes32 => uint256) private _timelocks;

    modifier onlyAuthorized() {
        require(_authorizedSpenders[msg.sender] || msg.sender == owner(), "Not authorized");
        _;
    }

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Deposits funds for a campaign
     * @param campaignId Campaign ID
     */
    function deposit(uint256 campaignId) external payable override {
        require(msg.value > 0, "Deposit amount must be > 0");
        
        _campaignBalances[campaignId] += msg.value;
        totalDeposited += msg.value;
        
        emit Deposited(campaignId, msg.sender, msg.value);
    }

    /**
     * @notice Withdraws funds (owner only)
     * @param recipient Recipient address
     * @param amount Amount to withdraw
     */
    function withdraw(
        address recipient,
        uint256 amount
    ) external override onlyOwner nonReentrant {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
        
        totalWithdrawn += amount;

        emit Withdrawn(recipient, amount);
    }

    /**
     * @notice Processes a payment from campaign balance
     * @dev Uses nonReentrant modifier to prevent reentrancy attacks
     * @param campaignId Campaign ID
     * @param recipient Recipient address
     * @param amount Amount to pay
     * @return bool True if successful
     */
    function processPayment(
        uint256 campaignId,
        address recipient,
        uint256 amount
    ) external override onlyAuthorized nonReentrant returns (bool) {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");
        require(_campaignBalances[campaignId] >= amount, "Insufficient campaign balance");

        _campaignBalances[campaignId] -= amount;

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Payment failed");

        emit PaymentProcessed(campaignId, recipient, amount);
        
        return true;
    }

    /**
     * @notice Gets campaign balance
     * @param campaignId Campaign ID
     * @return uint256 Balance
     */
    function getCampaignBalance(uint256 campaignId) external view override returns (uint256) {
        return _campaignBalances[campaignId];
    }

    /**
     * @notice Authorizes an address to spend from vault
     * @param spender Address to authorize
     */
    function authorizeSpender(address spender) external onlyOwner {
        require(spender != address(0), "Invalid spender");
        _authorizedSpenders[spender] = true;
    }

    /**
     * @notice Revokes spending authorization
     * @param spender Address to revoke
     */
    function revokeSpender(address spender) external onlyOwner {
        _authorizedSpenders[spender] = false;
    }

    /**
     * @notice Checks if address is authorized spender
     * @param spender Address to check
     * @return bool True if authorized
     */
    function isAuthorizedSpender(address spender) external view returns (bool) {
        return _authorizedSpenders[spender];
    }

    /**
     * @notice Gets total vault balance
     * @return uint256 Total balance
     */
    function getTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Emergency pause for large transfers
     * @param transferId Unique transfer identifier
     */
    function initializeTimelock(bytes32 transferId) external onlyOwner {
        _timelocks[transferId] = block.timestamp + TIMELOCK_DURATION;
    }

    /**
     * @notice Checks if timelock has expired
     * @param transferId Transfer identifier
     * @return bool True if expired
     */
    function isTimelockExpired(bytes32 transferId) external view returns (bool) {
        return block.timestamp >= _timelocks[transferId];
    }

    /**
     * @notice Batch deposit to multiple campaigns
     * @param campaignIds Array of campaign IDs
     * @param amounts Array of deposit amounts
     */
    function batchDeposit(
        uint256[] memory campaignIds,
        uint256[] memory amounts
    ) external payable {
        require(campaignIds.length == amounts.length, "Length mismatch");
        
        uint256 totalRequired = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalRequired += amounts[i];
        }
        require(msg.value == totalRequired, "Incorrect total amount");
        
        for (uint256 i = 0; i < campaignIds.length; i++) {
            _campaignBalances[campaignIds[i]] += amounts[i];
            emit Deposited(campaignIds[i], msg.sender, amounts[i]);
        }
    }

    /**
     * @notice Fallback to receive ETH
     */
    receive() external payable {
        emit Deposited(0, msg.sender, msg.value);
    }
}


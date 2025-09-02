// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FraudDetector
 * @notice Detects and prevents fraudulent conversions
 */
contract FraudDetector is Ownable {
    struct UserReputation {
        uint256 score;
        uint256 conversions;
        uint256 lastConversionTime;
        bool blacklisted;
    }

    mapping(address => UserReputation) private _userReputations;
    mapping(bytes32 => uint256) private _deviceScores;
    
    uint256 public constant MAX_REPUTATION_SCORE = 100;
    uint256 public constant MIN_REPUTATION_SCORE = 0;
    uint256 public constant INITIAL_REPUTATION = 50;
    uint256 public constant FRAUD_THRESHOLD = 20;
    uint256 public constant TIME_WINDOW = 1 hours;
    uint256 public constant MAX_CONVERSIONS_PER_WINDOW = 10;
    
    mapping(address => bool) private _trustedUsers;

    event UserScoreUpdated(address indexed user, uint256 newScore);
    event UserBlacklisted(address indexed user);
    event UserWhitelisted(address indexed user);
    event SuspiciousActivity(address indexed user, string reason);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Checks if a user/conversion is fraudulent
     * @dev Combines reputation score, blacklist status, rate limiting, and device scoring
     * @param user User address
     * @param deviceId Device identifier
     * @return bool True if legitimate
     */
    function checkFraud(
        address user,
        bytes32 deviceId
    ) external view returns (bool) {
        UserReputation memory reputation = _userReputations[user];

        // Check if blacklisted
        if (reputation.blacklisted) {
            return false;
        }

        // Check reputation score
        if (reputation.score < FRAUD_THRESHOLD) {
            return false;
        }

        // Check rate limiting
        if (reputation.lastConversionTime > 0 &&
            block.timestamp - reputation.lastConversionTime < TIME_WINDOW &&
            reputation.conversions >= MAX_CONVERSIONS_PER_WINDOW) {
            return false;
        }

        // Check device score
        if (_deviceScores[deviceId] < FRAUD_THRESHOLD) {
            return false;
        }

        return true;
    }

    /**
     * @notice Records a conversion and updates reputation
     * @param user User address
     * @param deviceId Device identifier
     * @param success Whether conversion was successful
     */
    function recordConversion(
        address user,
        bytes32 deviceId,
        bool success
    ) external onlyOwner {
        UserReputation storage reputation = _userReputations[user];

        // Initialize reputation if first conversion
        if (reputation.score == 0) {
            reputation.score = INITIAL_REPUTATION;
        }

        // Reset counter if outside time window
        if (block.timestamp - reputation.lastConversionTime >= TIME_WINDOW) {
            reputation.conversions = 0;
        }

        reputation.conversions += 1;
        reputation.lastConversionTime = block.timestamp;

        // Update score based on behavior
        if (success) {
            _increaseReputation(user);
        } else {
            _decreaseReputation(user);
        }

        // Update device score
        if (_deviceScores[deviceId] == 0) {
            _deviceScores[deviceId] = INITIAL_REPUTATION;
        }

        // Check for suspicious patterns
        if (reputation.conversions > MAX_CONVERSIONS_PER_WINDOW) {
            emit SuspiciousActivity(user, "Too many conversions in time window");
            _decreaseReputation(user);
        }
    }

    /**
     * @notice Gets user reputation
     * @param user User address
     * @return UserReputation struct
     */
    function getUserReputation(address user) external view returns (UserReputation memory) {
        return _userReputations[user];
    }

    /**
     * @notice Gets device score
     * @param deviceId Device identifier
     * @return uint256 Device score
     */
    function getDeviceScore(bytes32 deviceId) external view returns (uint256) {
        return _deviceScores[deviceId];
    }

    /**
     * @notice Blacklists a user
     * @param user User address
     */
    function blacklistUser(address user) external onlyOwner {
        _userReputations[user].blacklisted = true;
        emit UserBlacklisted(user);
    }

    /**
     * @notice Whitelists a user
     * @param user User address
     */
    function whitelistUser(address user) external onlyOwner {
        _userReputations[user].blacklisted = false;
        emit UserWhitelisted(user);
    }

    /**
     * @notice Sets user reputation score manually
     * @param user User address
     * @param score New score
     */
    function setUserScore(address user, uint256 score) external onlyOwner {
        require(score <= MAX_REPUTATION_SCORE, "Score too high");
        _userReputations[user].score = score;
        emit UserScoreUpdated(user, score);
    }

    /**
     * @notice Sets device score manually
     * @param deviceId Device identifier
     * @param score New score
     */
    function setDeviceScore(bytes32 deviceId, uint256 score) external onlyOwner {
        require(score <= MAX_REPUTATION_SCORE, "Score too high");
        _deviceScores[deviceId] = score;
    }

    /**
     * @notice Increases user reputation
     * @param user User address
     */
    function _increaseReputation(address user) private {
        UserReputation storage reputation = _userReputations[user];
        
        if (reputation.score < MAX_REPUTATION_SCORE) {
            reputation.score += 1;
            emit UserScoreUpdated(user, reputation.score);
        }
    }

    /**
     * @notice Decreases user reputation
     * @param user User address
     */
    function _decreaseReputation(address user) private {
        UserReputation storage reputation = _userReputations[user];
        
        if (reputation.score > MIN_REPUTATION_SCORE) {
            reputation.score -= 1;
            emit UserScoreUpdated(user, reputation.score);
            
            if (reputation.score < FRAUD_THRESHOLD) {
                emit SuspiciousActivity(user, "Reputation below threshold");
            }
        }
    }

    /**
     * @notice Checks if address is blacklisted
     * @param user User address
     * @return bool True if blacklisted
     */
    function isBlacklisted(address user) external view returns (bool) {
        return _userReputations[user].blacklisted;
    }

    /**
     * @notice Gets multiple user reputations
     * @param users Array of user addresses
     * @return UserReputation[] Array of reputations
     */
    function getBatchReputations(
        address[] memory users
    ) external view returns (UserReputation[] memory) {
        UserReputation[] memory reputations = new UserReputation[](users.length);
        
        for (uint256 i = 0; i < users.length; i++) {
            reputations[i] = _userReputations[users[i]];
        }
        
        return reputations;
    }
}


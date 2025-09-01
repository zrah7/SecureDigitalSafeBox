// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SecureDigitalSafeBox V2
 * @author Neo (Engineered by zrah7)
 * @notice A professional-grade, secure contract for depositing and withdrawing Ether.
 * @dev This contract uses OpenZeppelin's Ownable, ReentrancyGuard, and Pausable contracts for enhanced security and control.
 * It includes detailed event logging and robust access control.
 */

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract SecureDigitalSafeBox is Ownable, ReentrancyGuard, Pausable {

    // --- Events ---
    event Deposit(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawal(address indexed user, uint256 amount, uint256 timestamp);
    event ContractPaused(address account);
    event ContractUnpaused(address account);

    // --- State Variables ---
    mapping(address => uint256) private s_balances;

    // --- Constructor ---
    constructor() Ownable(msg.sender) {}

    // --- Main Functions ---
    function deposit() public payable nonReentrant whenNotPaused {
        require(msg.value > 0, "SafeBox: Deposit amount must be greater than zero.");
        s_balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() public nonReentrant whenNotPaused {
        uint256 userBalance = s_balances[msg.sender];
        require(userBalance > 0, "SafeBox: You have no balance to withdraw.");
        s_balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: userBalance}("");
        require(success, "SafeBox: Ether transfer failed.");
        emit Withdrawal(msg.sender, userBalance, block.timestamp);
    }

    // --- View Functions ---
    function getBalanceOf(address _user) public view returns (uint256) {
        return s_balances[_user];
    }

    // --- Admin Functions ---
    function pause() public onlyOwner {
        _pause();
        emit ContractPaused(msg.sender);
    }

    function unpause() public onlyOwner {
        _unpause();
        emit ContractUnpaused(msg.sender);
    }
}

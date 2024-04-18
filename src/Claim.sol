// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "forge-std/console.sol";

contract Claim is AccessControlEnumerable {
    using ECDSA for bytes32;

    error Claim_Only_Guardian();
    error Claim_Invalid_Signature();
    error Claim_Must_Have_Admin_Role();
    error Claim_Amount_Must_Be_Above_0();
    error Claim_Contract_Does_Not_Have_Enough_Tokens();
    error Claim_Recipient_Is_Address_0();
    error Claim_Message_Hash_Invalid();

    IERC20 public token;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyGuardian() {
        if (!hasRole(GUARDIAN_ROLE, msg.sender)) revert Claim_Only_Guardian();
        _;
    }

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender))
            revert Claim_Must_Have_Admin_Role();
        _;
    }

    modifier onlyWhenContractHasEnoughTokens(uint256 _amount) {
        if (token.balanceOf(address(this)) < _amount)
            revert Claim_Contract_Does_Not_Have_Enough_Tokens();
        _;
    }

    function grantNewRole(address account, bytes32 _role) external onlyAdmin {
        grantRole(_role, account);
    }

    function revokeExistingRole(
        address account,
        bytes32 _role
    ) external onlyAdmin {
        revokeRole(_role, account);
    }

    function claimToken(
        uint256 _amount,
        address _recipient,
        bytes32 _messageHash,
        bytes memory _signature
    ) external onlyWhenContractHasEnoughTokens(_amount) {
        if (_amount == 0) revert Claim_Amount_Must_Be_Above_0();
        if (_recipient == address(0)) revert Claim_Recipient_Is_Address_0();
        bytes32 expectedMessageHash = keccak256(
            abi.encodePacked(_amount, _recipient)
        );
        if (expectedMessageHash != _messageHash)
            revert Claim_Message_Hash_Invalid();

        bytes32 messageHash = _messageHash.toEthSignedMessageHash();
        // Verify the signature
        address signer = messageHash.recover(_signature);
        if (!hasRole(SIGNER_ROLE, signer)) revert Claim_Invalid_Signature();
        token.transfer(_recipient, _amount);
    }

    function withdrawToken(
        address _recipient,
        uint256 _amount
    ) external onlyGuardian onlyWhenContractHasEnoughTokens(_amount) {
        token.transfer(_recipient, _amount);
    }
}

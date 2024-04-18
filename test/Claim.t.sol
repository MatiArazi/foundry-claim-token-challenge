// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DeployClaim, Claim, MyToken} from "../script/DeployClaim.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ClaimTest is Test {
    using ECDSA for bytes32;

    DeployClaim public deployer;
    Claim public claim;
    MyToken public myToken;

    uint256 internal _userPrivateKey = 0xa11ce;
    uint256 internal _signerPrivateKey = 0xabc123;
    address public user = vm.addr(_userPrivateKey);
    address public signer = vm.addr(_signerPrivateKey);

    function setUp() public {
        deployer = new DeployClaim();
        (claim, myToken) = deployer.run();
        vm.startBroadcast();

        claim.grantNewRole(signer, claim.SIGNER_ROLE());
        vm.stopBroadcast();
    }

    function testInit() public view {
        assert(address(myToken) == address(claim.token()));
        assert(myToken.balanceOf(address(claim)) == 1000e18);
        assert(claim.hasRole(claim.SIGNER_ROLE(), signer));
    }

    function testClaimToken() public {
        uint256 amount = 10e18;

        vm.startPrank(signer);
        bytes32 message = keccak256(abi.encodePacked(amount, user));
        bytes32 digest = message.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();

        vm.startPrank(user);

        claim.claimToken(amount, user, message, signature);
        vm.stopPrank();

        assert(myToken.balanceOf(user) == 10e18);
        assert(myToken.balanceOf(address(claim)) == 990e18);
    }

    function testRevertClaimWithRecipientZero() public {
        uint256 amount = 10e18;

        vm.startPrank(signer);
        bytes32 message = keccak256(abi.encodePacked(user, amount));
        bytes32 digest = message.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert(Claim.Claim_Recipient_Is_Address_0.selector);
        claim.claimToken(amount, address(0), message, signature);
        vm.stopPrank();

        assert(myToken.balanceOf(user) == 0);
        assert(myToken.balanceOf(address(claim)) == 1000e18);
    }

    function testRevertClaimInvalidMessage() public {
        uint256 amount = 10e18;

        vm.startPrank(signer);
        bytes32 message = keccak256(abi.encodePacked("hello"));
        bytes32 digest = message.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert(Claim.Claim_Message_Hash_Invalid.selector);
        claim.claimToken(amount, user, message, signature);
        vm.stopPrank();

        assert(myToken.balanceOf(user) == 0);
        assert(myToken.balanceOf(address(claim)) == 1000e18);
    }
}

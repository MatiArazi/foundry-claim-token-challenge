// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Test, console2} from "forge-std/Test.sol";

contract SigningExample {
    using ECDSA for bytes32;

    address public systemAddress;

    function setSystemAddress(address _address) external {
        systemAddress = _address;
    }

    function purchase(
        uint256 _amount,
        string calldata _nonce,
        bytes calldata _signature
    ) external payable {
        require(
            isValidSignature(
                systemAddress,
                keccak256(abi.encodePacked(msg.sender, _amount, _nonce)),
                _signature
            ),
            "Invalid Signature"
        );

        // mint tokens
    }

    function isValidSignature(
        address _systemAddress,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        require(_systemAddress != address(0), "Missing System Address");

        bytes32 signedHash = hash.toEthSignedMessageHash();
        return signedHash.recover(signature) == _systemAddress;
    }
}

contract SigningExampleTest is Test {
    using ECDSA for bytes32;

    SigningExample public signingExample;

    uint256 internal userPrivateKey;
    uint256 internal signerPrivateKey;

    function setUp() public {
        signingExample = new SigningExample();

        userPrivateKey = 0xa11ce;
        signerPrivateKey = 0xabc123;

        address signer = vm.addr(signerPrivateKey);
        signingExample.setSystemAddress(signer);
    }

    function testPurchase() public {
        address user = vm.addr(userPrivateKey);
        address signer = vm.addr(signerPrivateKey);

        uint256 amount = 2;
        string memory nonce = "QSfd8gQE4WYzO29";

        vm.startPrank(signer);
        bytes32 digest = keccak256(abi.encodePacked(user, amount, nonce))
            .toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();

        vm.startPrank(user);
        // Give the user some ETH, just for good measure
        vm.deal(user, 1 ether);

        signingExample.purchase(amount, nonce, signature);
        vm.stopPrank();
    }
}

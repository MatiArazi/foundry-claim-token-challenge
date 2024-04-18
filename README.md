## Claim Token Challenge

**Assume there is a rewards program for users, so they get some tokens by doing some actions. Their actions are saved by a database. The users can go to a webpage and claim their rewards -- the server checks the amount to redeem, at which point it signs the message to allow it to go through. The following Smart Contract enables users to claim those tokens after receiving a signed message by a trusted wallet (signature made by our secured backend and then passed to the FE to construct the Tx parameters). It has some vulnerabilities in the claimToken function. Find those issues, explain them and propose changes to fix them.**

See code: [`./src/OldClaim.sol`](https://github.com/MatiArazi/foundry-claim-token-challenge/blob/main/src/OldClaim.sol)

Corrected code [`./src/Claim.sol`](https://github.com/MatiArazi/foundry-claim-token-challenge/blob/main/src/Claim.sol)

## Issues
1. Started by moving the if statement where it checks if `_amount == 0` to the top.
2. Then I checked if `_recipient == address(0)`, although it's checked in the transfer, it's better if it's checked before, to avoid unnecessary operations.
3. Additionally, I verified if `_messageHash` is not a random message. Therefore, I declared `bytes32 expectedMessageHash = keccak256(abi.encodePacked(_amount, _recipient))` and compared it with `_messageHash`. They should be equal; if not, it reverts.
4. After all these checks, I proceeded with the function logic, which was already implemented.

## Tests
You can look into the [`./test`](https://github.com/MatiArazi/foundry-claim-token-challenge/blob/main/test) folder and compare the test on both contracts and evidence the issues en `OldClaim` and how they are fixed on `Claim`.

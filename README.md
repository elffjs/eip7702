This is a near-complete rip off of [the Odyssey example](https://github.com/ithacaxyz/odyssey-examples/blob/main/chapter1/contracts/src/ERC20Fee.sol). Thank you, Paradigm!

1. Start Anvil in Odyssey mode to gain EIP-7702 support.
   ```sh
   anvil --odyssey
   ```
2. Alice will have the EIP-7702 wallet. Bob is someone who's willing to execute Alice's transactions in exchange for a flat ERC-20 fee.
3. Set up some variables:
   ```sh
   export ALICE_ADDR=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
   export ALICE_PK=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   export BOB_ADDR=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
   export BOB_PK=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
   export EVE_ADDR=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
   ```
4. For simplicity, we'll have Alice deploy the ERC-20 and so come into possession of a lot of tokens.
   ```sh
   forge create FakeERC20 --private-key $ALICE_PK
   export ERC20_ADDR=0x5FbDB2315678afecb367f032d93F642f64180aa3
   ```
   For simplicity we've hardcoded this address into the account. As long as you do everything in this order it should match.
5. Now we deploy the implementation contract for our account:
   ```sh
   forge create Account --private-key $ALICE_PK
   export IMPL_ADDR=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
   ```
6. Alice signs the authorization, and then creates the signature for `execute`. We'll send 10 wei to Eve.
   ```sh
   SIGNED_AUTH=$(cast wallet sign-auth $IMPL_ADDR --private-key $ALICE_PK)
   SIGNED=$(cast wallet sign --no-hash $(cast keccak256 $(cast abi-encode 'f(uint256,address,uint256,bytes)' 0 $EVE_ADDR 10 0x)) --private-key $ALICE_PK)
   V=$(echo $SIGNED | cut -b 1-2,131-132)
   R=$(echo $SIGNED | cut -b 1-66)
   S=$(echo $SIGNED | cut -b 1-2,67-130)
   ```
7. Bob submits the authorization and a first execution:
   ```sh
   cast send $ALICE_ADDR "execute(address,uint256,bytes,uint8,bytes32,bytes32)" $EVE_ADDR 10 0x V $R $S  --private-key $BOB_PK --auth $SIGNED_AUTH
   ```
8. We can check that Eve did receive Ethereum, and that Bob got his fee:
   ```sh
   cast balance $EVE_ADDR
   cast call $ERC20_ADDR "balances(address)(uint256)" $BOB_ADDR
   ```

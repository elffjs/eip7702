// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract FakeERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    mapping(address => uint256) public balances;

    constructor() {
        balances[msg.sender] = 1_000_000_000 ether;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}

contract Account {
    IERC20 public constant token = IERC20(0x5FbDB2315678afecb367f032d93F642f64180aa3);

    uint256 public executeNonce;

    function execute(address to, uint256 value, bytes memory data, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 digest = keccak256(abi.encode(executeNonce++, to, value, data));
        address signer = ecrecover(digest, v, r, s);

        require(signer == address(this));

        (bool success,) = to.call{value: value}(data);
        require(success);

        require(token.transfer(msg.sender, 1 ether));
    }
}

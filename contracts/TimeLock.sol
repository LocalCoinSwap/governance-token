pragma solidity ^0.4.19;

// Token interface
contract Token {
    function transfer(address _to, uint256 _value) public returns (bool);
    function balanceOf(address _for) public returns (uint256);
}

// Contract to freeze deposited ERC20 tokens for a set amount of time
contract TimeLock {
    Token public token;
    uint256 public releaseTime;
    address public owner;

    function TimeLock(address _token, uint256 _releaseTime) public {
        require(_releaseTime > now);
        token = Token(_token);
        releaseTime = _releaseTime;
        owner = msg.sender;
    }

    // Claim deposited tokens after release time has passed
    function claim() public returns (bool) {
        require(msg.sender == owner);
        require(now > releaseTime);
        token.transfer(owner, token.balanceOf(address(this)));
        return true;
    }
}

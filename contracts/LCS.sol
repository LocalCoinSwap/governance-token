pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract DerivativeTokenInterface {
    function mint(address _to, uint256 _amount) public returns (bool);
}

contract LCS is StandardToken, BurnableToken, Ownable {
    string public constant name = "LocalCoinSwap Cryptoshare";
    string public constant symbol = "LCS";
    uint256 public constant decimals = 18;
    uint256 public constant initialSupply = 100000000 * (10 ** 18);

    // Array of derivative token addresses
    DerivativeTokenInterface[] public derivativeTokens;

    bool public nextDerivativeTokenScheduled = false;

    // Time until next token distribution
    uint256 public nextDerivativeTokenTime;

    // Next token to be distrubuted
    DerivativeTokenInterface public nextDerivativeToken;

    // Index of last token claimed by LCS holder, required for holder to claim unclaimed tokens
    mapping (address => uint256) lastDerivativeTokens;

    function LCS() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
        Transfer(0, msg.sender, totalSupply_);
    }

    // Event for token distribution
    event DistributeDerivativeTokens(address indexed to, uint256 number, uint256 amount);

    // Modifier to handle token distribution
    modifier handleDerivativeTokens(address from) {
        if (nextDerivativeTokenScheduled && now > nextDerivativeTokenTime) {
            derivativeTokens.push(nextDerivativeToken);

            nextDerivativeTokenScheduled = false;

            delete nextDerivativeTokenTime;
            delete nextDerivativeToken;
        }

        for (uint256 i = lastDerivativeTokens[from]; i < derivativeTokens.length; i++) {
            // Since tokens haven't redeemed yet, mint new ones and send them to LCS holder
            derivativeTokens[i].mint(from, balances[from]);
            DistributeDerivativeTokens(from, i, balances[from]);
        }

        lastDerivativeTokens[from] = derivativeTokens.length;

        _;
    }

    // Claim unclaimed derivative tokens
    function claimDerivativeTokens() public handleDerivativeTokens(msg.sender) returns (bool) {
        return true;
    }

    // Set the address and release time of the next token distribution
    function scheduleNewDerivativeToken(address _address, uint256 _time) public onlyOwner returns (bool) {
        require(!nextDerivativeTokenScheduled);

        nextDerivativeTokenScheduled = true;
        nextDerivativeTokenTime = _time;
        nextDerivativeToken = DerivativeTokenInterface(_address);

        return true;
    }

    // Make sure derivative tokens are handled for the _from and _to addresses
    function transferFrom(address _from, address _to, uint256 _value) public handleDerivativeTokens(_from) handleDerivativeTokens(_to) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    // Make sure derivative tokens are handled for the msg.sender and _to addresses
    function transfer(address _to, uint256 _value) public handleDerivativeTokens(msg.sender) handleDerivativeTokens(_to) returns (bool) {
        return super.transfer(_to, _value);
    }
}

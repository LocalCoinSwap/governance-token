pragma solidity ^0.4.19;

import "./DerivativeToken.sol";

// Contract for Distribution token to allow dividend payment of owed cryptocurrencies
contract DistributionToken is DerivativeToken {

    // Store count of tokens spent and label
    struct Spends {
        uint256 count;
        string label;
    }

    // Array of Spends
    Spends[] public spends;

    // Event triggered when tokens are spent
    event Spend(address indexed from, uint256 amount, string label);

    function DistributionToken(string _name, string _symbol) public {
        totalSupply_ = 0;
        symbol = _symbol;
        name = _name;
    }

    // Return number of spends
    function numberOfSpends() public view returns (uint256) {
        return spends.length;
    }

    // Spend desired amount of tokens from address provided, label is used to identify spender
    function spendFrom(address _from, uint256 _count, string _label) public returns (bool) {
        require(_count <= balances[_from]);
        require(_count <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_count);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_count);
        totalSupply_ = totalSupply_.sub(_count);

        spends.push(Spends({count: _count, label: _label}));
        Spend(msg.sender, _count, _label);

        return true;
    }

    // Spend desired amount of tokens from address calling function, label is used to identify spender
    function spend(uint256 _count, string _label) public returns (bool) {
        require(_count <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_count);
        totalSupply_ = totalSupply_.sub(_count);

        spends.push(Spends({count: _count, label: _label}));
        Spend(msg.sender, _count, _label);

        return true;
    }
}

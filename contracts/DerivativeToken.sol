pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract DerivativeToken is StandardToken, Ownable {
    string public name;
    string public symbol;
    uint256 public decimals = 18;

    event Mint(address indexed to, uint256 amount);

    // Function to mint Derivative Tokens for LCS holders
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }
}

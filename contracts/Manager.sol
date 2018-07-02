pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./DerivativeToken.sol";
import "./DistributionToken.sol";
import "./VotingToken.sol";

contract LCSInterface {
    function scheduleNewDerivativeToken(address _address, uint256 _time) public returns (bool);
}

// Management contract to allow scheduling of Distribution and Voting tokens to LCS contract
contract Manager is Ownable {
    LCSInterface public lcs;

    function Manager(address _lcs) public {
        lcs = LCSInterface(_lcs);
    }

    // Schedule new Derivative token, used by other scheduling functions
    function newDerivativeToken(DerivativeToken _token, uint256 _time) private returns (bool) {
        _token.transferOwnership(address(lcs));
        return lcs.scheduleNewDerivativeToken(address(_token), _time);
    }

    // Schedule new Distribution token
    function newDistributionToken(string _name, string _symbol, uint256 _time) public onlyOwner returns (bool) {
        return newDerivativeToken(new DistributionToken(_name, _symbol), _time);
    }

    // Schedule new Voting token
    function newVotingToken(string _name, string _symbol, uint256 _voteStartTime, uint256 _voteEndTime) public onlyOwner returns (bool) {
        return newDerivativeToken(new VotingToken(_name, _symbol, msg.sender, _voteStartTime, _voteEndTime), _voteStartTime);
    }
}

pragma solidity ^0.4.19;

import "./DerivativeToken.sol";

contract VotingToken is DerivativeToken {
    // Choice to vote on
    struct Choice {
        string label;
        uint256 votes;
    }

    // Array of choices to vote on
    Choice[] public choices;

    // Delegate to add choices
    address public delegate;

    // Voting times
    uint256 public voteStartTime;
    uint256 public voteEndTime;

    function VotingToken(string _name, string _symbol, address _delegate, uint256 _voteStartTime, uint256 _voteEndTime) public {
        totalSupply_ = 0;
        symbol = _symbol;
        name = _name;

        delegate = _delegate;

        require(_voteStartTime > now);
        require(_voteEndTime > _voteStartTime);

        voteStartTime = _voteStartTime;
        voteEndTime = _voteEndTime;
    }

    modifier delegateOnly() {
        require(delegate == msg.sender);

        _;
    }

    modifier beforeVoteOnly() {
        require(voteStartTime > now);

        _;
    }

    modifier duringVoteOnly() {
        require(voteStartTime < now && voteEndTime > now);

        _;
    }

    // Push the given choice with the label into the array of choices
    function addChoice(string _label) public delegateOnly beforeVoteOnly returns (bool) {
        choices.push(Choice({label: _label, votes: 0}));
        return true;
    }

    // Event for voting
    event Vote(address indexed _by, uint256 _choice, uint256 _count);

    // Select choice index from choices and vote desired amount for address calling function
    function vote(uint256 _choice, uint256 _count) public duringVoteOnly returns (bool) {
        require(_choice >= 0);
        require(_choice < choices.length);

        require(_count <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_count);
        totalSupply_ = totalSupply_.sub(_count);
        choices[_choice].votes = choices[_choice].votes.add(_count);

        Vote(msg.sender, _choice, _count);

        return true;
    }

    // Select choice index from choices and vote desired amount for address supplied
    function voteFrom(address _from, uint256 _choice, uint256 _count) public duringVoteOnly returns (bool) {
        require(_choice >= 0);
        require(_choice < choices.length);

        require(_count <= balances[_from]);
        require(_count <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_count);
        totalSupply_ = totalSupply_.sub(_count);
        choices[_choice].votes = choices[_choice].votes.add(_count);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_count);

        Vote(msg.sender, _choice, _count);

        return true;
    }
}

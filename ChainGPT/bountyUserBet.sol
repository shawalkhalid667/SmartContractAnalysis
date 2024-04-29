
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's contract for safe math operations
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Importing Oraclize
import "https://github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

contract BountyUserBet is usingOraclize {
    using SafeMath for uint256;

    // Defining the data structures
    struct UserBet {
        uint id;
        uint tip;
        string prediction;
    }

    struct Winner {
        uint id;
        uint points;
    }

    struct Request {
        string id;
        string matchData;
    }

    // Storing user bets and pot amount
    mapping(address => UserBet) public userBets;
    uint public pot;

    // Storing winners and API requests
    mapping(address => Winner) public winners;
    mapping(bytes32 => Request) public requests;

    // Events for Oraclize queries and API results
    event LogNewOraclizeQuery(string description);
    event LogNewAPIData(string data);

    // Modifiers and functions to control API data phase transitions and convert string results to uint
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function __callback(bytes32 myid, string result) public {
        require(msg.sender == oraclize_cbAddress());
        requests[myid].matchData = result;
        emit LogNewAPIData(result);
    }

    function fetchMatchData(string memory matchId) public payable onlyOwner {
        require(oraclize_getPrice("URL") <= address(this).balance, "Not enough Ether to retrieve API data.");

        emit LogNewOraclizeQuery("Oraclize query was sent, waiting for the data..");

        // Generating the API call URL
        string memory url = strConcat("http://api.sportsdata.io/v3/soccer/scores/json/Match/", matchId);

        // Creating a new Oraclize request
        bytes32 queryId = oraclize_query("URL", url);
        requests[queryId] = Request(matchId, "");
    }

    // Function to get all user bets
    function getAllUserBets() public view returns(UserBet[] memory) {
        UserBet[] memory userBetsArray = new UserBet[](address(this).balance);
        for (uint i = 0; i < address(this).balance; i++) {
            UserBet storage userBet = userBets[address(i)];
            userBetsArray[i] = userBet;
        }
        return userBetsArray;
    }

    // Function to display winners with their points
    function displayWinners() public view returns(Winner[] memory) {
        Winner[] memory winnersArray = new Winner[](address(this).balance);
        for (uint i = 0; i < address(this).balance; i++) {
            Winner storage winner = winners[address(i)];
            winnersArray[i] = winner;
        }
        return winnersArray;
    }
}

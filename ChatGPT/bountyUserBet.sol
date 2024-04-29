pragma solidity ^0.8.0;

import "github.com/oraclize/ethereum-api/provableAPI.sol";

contract BountyUserBet is usingProvable {
    
    address public owner;
    uint public potAmount;
    uint public homeScore;
    uint public awayScore;
    bool public scoresFetched;
    
    struct UserBet {
        uint id;
        address userAddress;
        uint tip;
    }
    
    struct Winner {
        address winnerAddress;
        uint winnings;
    }
    
    struct Request {
        bytes32 id;
        string url;
    }
    
    mapping(uint => UserBet) public userBets;
    uint public totalUserBets;
    mapping(address => uint) public userPoints;
    Winner[] public winners;
    Request public apiRequest;
    
    event NewOraclizeQuery(string description);
    event NewApiResult(string result);
    event WinnerAnnounced(address winner, uint winnings);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier scoresNotFetched() {
        require(!scoresFetched, "Scores already fetched");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        potAmount = 0;
        scoresFetched = false;
        totalUserBets = 0;
    }
    
    function bet(uint _tip) external payable {
        require(msg.value > 0, "Invalid bet amount");
        
        uint betId = totalUserBets++;
        userBets[betId] = UserBet(betId, msg.sender, _tip);
        potAmount += msg.value;
    }
    
    function fetchScores(string memory _url) external onlyOwner scoresNotFetched {
        apiRequest.id = provable_query("URL", _url);
        apiRequest.url = _url;
        emit NewOraclizeQuery("Scores fetch request sent");
    }
    
    function __callback(bytes32 _id, string memory _result) public override {
        require(msg.sender == provable_cbAddress(), "Invalid callback");
        require(_id == apiRequest.id, "Invalid callback ID");
        
        (homeScore, awayScore) = parseIntegers(_result);
        scoresFetched = true;
        emit NewApiResult(_result);
    }
    
    function parseIntegers(string memory _input) private pure returns (uint, uint) {
        bytes memory bResult = bytes(_input);
        uint commaPos = findComma(bResult);
        uint home = toUint(bResult, 0, commaPos);
        uint away = toUint(bResult, commaPos + 1, bResult.length - commaPos - 1);
        return (home, away);
    }
    
    function findComma(bytes memory _bytes) private pure returns (uint) {
        for (uint i = 0; i < _bytes.length; i++) {
            if (_bytes[i] == bytes1(',')) {
                return i;
            }
        }
        revert("Comma not found");
    }
    
    function toUint(bytes memory _bytes, uint _start, uint _length) private pure returns (uint) {
        uint result = 0;
        for (uint i = _start; i < _start + _length; i++) {
            result = result * 10 + (uint8(_bytes[i]) - 48);
        }
        return result;
    }
    
    function setWinners(uint _homeScore, uint _awayScore) external onlyOwner {
        require(scoresFetched, "Scores not fetched yet");
        
        for (uint i = 0; i < totalUserBets; i++) {
            if (userBets[i].tip == _homeScore) {
                winners.push(Winner(userBets[i].userAddress, potAmount));
                userPoints[userBets[i].userAddress]++;
            }
            if (userBets[i].tip == _awayScore) {
                winners.push(Winner(userBets[i].userAddress, potAmount));
                userPoints[userBets[i].userAddress]++;
            }
        }
        
        emit WinnerAnnounced(winners[winners.length-1].winnerAddress, winners[winners.length-1].winnings);
    }
    
    function getUserBets() external view returns (UserBet[] memory) {
        UserBet[] memory bets = new UserBet[](totalUserBets);
        for (uint i = 0; i < totalUserBets; i++) {
            bets[i] = userBets[i];
        }
        return bets;
    }
    
    function displayWinners() external view returns (Winner[] memory) {
        return winners;
    }
    
    function generateApiUrl(string memory _params) public pure returns (string memory) {
        // Generate API URL based on input parameters
        return _params;
    }
    
    function withdraw() external {
        uint amount = userPoints[msg.sender] * potAmount / winners.length;
        require(amount > 0, "No winnings to withdraw");
        
        userPoints[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

pragma solidity ^0.8.0;

contract KtonVoter {
    address public KTON;
    
    struct Voter {
        uint256 votes;
        uint256 balance;
    }
    
    struct Candidate {
        uint256 voteCount;
        uint256 sortedIndex;
        bool registered;
    }
    
    mapping(address => Voter) public voterItems;
    mapping(address => Candidate) public candidateItems;
    address[] public sortedCandidates;
    
    constructor(address _kton) {
        KTON = _kton;
    }
    
    function vote(uint256 amount, address candidate) external {
        require(amount > 0, "Amount must be greater than 0");
        require(voterItems[msg.sender].balance >= amount, "Insufficient balance");
        
        voterItems[msg.sender].votes += amount;
        voterItems[msg.sender].balance -= amount;
        
        candidateItems[candidate].voteCount += amount;
        
        if (candidateItems[candidate].sortedIndex == 0) {
            sortedCandidates.push(candidate);
            candidateItems[candidate].sortedIndex = sortedCandidates.length;
            quickSort(0, int(sortedCandidates.length - 1));
        }
    }
    
    function withdrawFrom(address candidate, uint256 amount) external {
        require(amount <= voterItems[msg.sender].votes, "Insufficient votes to withdraw");
        
        voterItems[msg.sender].votes -= amount;
        voterItems[msg.sender].balance += amount;
        
        candidateItems[candidate].voteCount -= amount;
    }
    
    function getCandidate(uint256 index) external view returns (address) {
        require(index < sortedCandidates.length, "Index out of bounds");
        return sortedCandidates[index];
    }
    
    function registerCandidate() external {
        require(!candidateItems[msg.sender].registered, "Already registered as a candidate");
        candidateItems[msg.sender].registered = true;
    }
    
    function quickSort(int left, int right) internal {
        if (left < right) {
            int pivotIndex = left + (right - left) / 2;
            uint256 pivotValue = candidateItems[sortedCandidates[uint(pivotIndex)]].voteCount;
            int i = left - 1;
            int j = right + 1;
            
            while (true) {
                do {
                    i++;
                } while (candidateItems[sortedCandidates[uint(i)]].voteCount > pivotValue);
                
                do {
                    j--;
                } while (candidateItems[sortedCandidates[uint(j)]].voteCount < pivotValue);
                
                if (i >= j) break;
                
                (sortedCandidates[uint(i)], sortedCandidates[uint(j)]) = (sortedCandidates[uint(j)], sortedCandidates[uint(i)]);
            }
            
            quickSort(left, j);
            quickSort(j + 1, right);
        }
    }
}

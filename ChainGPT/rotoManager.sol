
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RotoManager is Ownable, Pausable {
    using SafeMath for uint256;

    ERC20 public rotoToken;

    struct Tournament {
        uint256 id;
        bool isActive;
        uint256 prizePool;
    }

    mapping(address => uint256) public stakes;
    mapping(uint256 => Tournament) public tournaments;
    uint256 public tournamentCounter;

    event TournamentCreated(uint256 indexed tournamentId, uint256 prizePool);
    event TournamentClosed(uint256 indexed tournamentId);
    event Staked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event TokenReleased(address indexed user, uint256 amount);

    constructor(address _rotoToken) {
        rotoToken = ERC20(_rotoToken);
    }

    function stake(uint256 _amount) external whenNotPaused {
        rotoToken.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = stakes[msg.sender].add(_amount);
        emit Staked(msg.sender, _amount);
    }

    function createTournament(uint256 _prizePool) external onlyOwner {
        tournamentCounter = tournamentCounter.add(1);
        tournaments[tournamentCounter] = Tournament(tournamentCounter, true, _prizePool);
        emit TournamentCreated(tournamentCounter, _prizePool);
    }

    function closeTournament(uint256 _tournamentId) external onlyOwner {
        Tournament storage tournament = tournaments[_tournamentId];
        require(tournament.isActive == true, "Tournament already closed");
        tournament.isActive = false;
        emit TournamentClosed(_tournamentId);
    }

    function releaseRoto(address _to, uint256 _amount) external onlyOwner {
        require(rotoToken.balanceOf(address(this)) >= _amount, "Not enough ROTO tokens in contract");
        rotoToken.transfer(_to, _amount);
        emit TokenReleased(_to, _amount);
    }

    function rewardRoto(address _to, uint256 _amount) external onlyOwner {
        require(rotoToken.balanceOf(address(this)) >= _amount, "Not enough ROTO tokens in contract");
        rotoToken.transfer(_to, _amount);
        emit RewardPaid(_to, _amount);
    }

    function destroyRoto(uint256 _amount) external onlyOwner {
        rotoToken.burn(_amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

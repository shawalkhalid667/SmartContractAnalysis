
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's ERC721 implementation
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Importing OpenZeppelin's Roles library
import "@openzeppelin/contracts/access/AccessControl.sol";

// ADM312 contract for managing admin roles and contract addresses
contract ADM312 is AccessControl {
    // Define roles for COO, CTO, and CFO
    bytes32 public constant COO_ROLE = keccak256("COO_ROLE");
    bytes32 public constant CTO_ROLE = keccak256("CTO_ROLE");
    bytes32 public constant CFO_ROLE = keccak256("CFO_ROLE");

    constructor() {
        _setupRole(COO_ROLE, msg.sender);
        _setupRole(CTO_ROLE, msg.sender);
        _setupRole(CFO_ROLE, msg.sender);
    }

    // Modifier to check caller's role
    modifier onlyCOO() {
        require(hasRole(COO_ROLE, msg.sender), "Caller is not a COO");
        _;
    }

    modifier onlyCTO() {
        require(hasRole(CTO_ROLE, msg.sender), "Caller is not a CTO");
        _;
    }

    modifier onlyCFO() {
        require(hasRole(CFO_ROLE, msg.sender), "Caller is not a CFO");
        _;
    }
}

// CryptoAtoms contract
contract CryptoAtoms is ADM312, ERC721 {
    struct Atom {
        string dna;
        uint256 generation;
        uint256 level;
    }

    Atom[] public atoms;
    mapping (address => uint256) private _balances;

    constructor() ERC721("CryptoAtoms", "ATOM") {}

    // Function to create a new atom
    function createAtom(string memory _dna, uint256 _generation, uint256 _level) public onlyCOO returns (uint256) {
        Atom memory _atom = Atom({
            dna: _dna,
            generation: _generation,
            level: _level
        });

        atoms.push(_atom);
        uint256 newAtomId = atoms.length - 1;
        _mint(msg.sender, newAtomId);

        return newAtomId;
    }

    // Function to transfer atom
    function transferAtom(address _to, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You do not own this atom");
        transferFrom(msg.sender, _to, _tokenId);
    }

    // Function to update atom's properties
    function setAtomProperties(uint256 _tokenId, string memory _dna, uint256 _generation, uint256 _level) public onlyCTO {
        require(_exists(_tokenId), "Atom does not exist");
        Atom storage atom = atoms[_tokenId];

        atom.dna = _dna;
        atom.generation = _generation;
        atom.level = _level;
    }

    // Function to withdraw ETH from the contract
    function withdraw() public onlyCFO {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}

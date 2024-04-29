// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/**
 *  @title Simple Deal Marketplace
 *  @dev Created in Swarm City anno 2017,
 *  for the world, with love.
 *  description Symmetrical Escrow Deal Contract
 *  description This is the marketplace contract for creating Swarm City marketplaces.
 *  It's the first, most simple approach to making Swarm City work.
 *  This contract creates "SimpleDeals".
 */

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { Auth, Authority } from 'solmate/auth/Auth.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { MintableERC20 } from './MintableERC20.sol';

// @notice Status enum
enum Status {
	None,
	Open,
	Funded,
	Done,
	Disputed,
	Resolved,
	Cancelled
}

contract Marketplace is Auth {
	/// @dev name The human readable name of the marketplace
	/// @dev fee The fixed marketplace fee in the specified token
	/// @dev token The token for fees
	/// @dev providerRep The rep token that is minted for the Provider
	/// @dev seekerRep The rep token that is minted for the Seeker
	/// @dev payoutaddress The address where the marketplace fee is sent.
	/// @dev metadataHash The IPFS hash metadata for this marketplace
	string public name;
	uint256 public fee;
	ERC20 public token;
	MintableERC20 public providerRep;
	MintableERC20 public seekerRep;
	address public payoutAddress;
	string public metadataHash;
	bool public initialized = false;

	/// @param dealStruct The deal object.
	/// @param status Coming from Status enum.
	/// Statuses: Open, Done, Disputed, Resolved, Cancelled
	/// @param fee The value of the marketplace fee is stored in the deal. This prevents the marketplacemaintainer to influence an existing deal when changing the marketplace fee.
	/// @param dealValue The value of the deal (SWT)
	/// @param provider The address of the provider
	/// @param deals Array of deals made by this marketplace

	struct Item {
		Status status;
		uint256 fee;
		uint256 price;
		uint256 deposit;
		uint256 providerRep;
		uint256 seekerRep;
		address providerAddress;
		address seekerAddress;
		bytes32 metadata;
	}

	uint256 public itemId;
	mapping(uint256 => Item) public items;
	mapping(bytes => bool) invalidatedSignatures;

	/// @dev Event NewDealForTwo - This event is fired when a new deal for two is created.
	event NewItem(
		address indexed owner,
		uint256 indexed id,
		bytes32 metadata,
		uint256 price,
		uint256 deposit,
		uint256 fee,
		uint256 seekerRep,
		uint256 timestamp
	);

	/// @dev Event FundDeal - This event is fired when a deal is been funded by a party.
	event FundItem(address indexed provider, uint256 indexed id);

	/// @dev DealStatusChange - This event is fired when a deal status is updated.
	event ItemStatusChange(uint256 indexed id, Status newstatus);

	/// @dev marketplaceChanged - This event is fired when the payout address is changed.
	event SetPayoutAddress(address payoutAddress);

	/// @dev marketplaceChanged - This event is fired when the metadata hash is changed.
	event SetMetadataHash(string metadataHash);

	/// @dev marketplaceChanged - This event is fired when the marketplace fee is changed.
	event SetFee(uint256 fee);

	// EIP-712
	uint256 internal INITIAL_CHAIN_ID;
	bytes32 internal INITIAL_DOMAIN_SEPARATOR;

	/// @notice The function that creates the marketplace
	constructor() Auth(address(0), Authority(address(0))) {}

	/// @notice The function that initializes the marketplace
	function init(
		address _token,
		string memory _name,
		uint256 _fee,
		string memory _metadataHash,
		address _owner,
		MintableERC20 _seekerRep,
		MintableERC20 _providerRep
	) public {
		require(!initialized, 'ALREADY_INITIALIZED');

		// Prevent re-initialization
		initialized = true;

		// Set first item id at 1
		itemId = 1;

		// Reputation tokens
		seekerRep = _seekerRep;
		providerRep = _providerRep;

		// Global config
		name = _name;
		token = ERC20(_token);
		metadataHash = _metadataHash;
		fee = _fee;
		payoutAddress = _owner;

		// Auth
		owner = _owner;

		// EIP-712
		INITIAL_CHAIN_ID = block.chainid;
		INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
	}

	/// @notice The Marketplace owner can always update the payout address.
	function setPayoutAddress(address _payoutaddress) public requiresAuth {
		payoutAddress = _payoutaddress;
		emit SetPayoutAddress(payoutAddress);
	}

	/// @notice The Marketplace owner can always update the metadata for the marketplace.
	function setMetadataHash(string calldata _metadataHash) public requiresAuth {
		metadataHash = _metadataHash;
		emit SetMetadataHash(metadataHash);
	}

	/// @notice The Marketplace owner can always change the marketplace fee amount
	function setFee(uint256 _fee) public requiresAuth {
		fee = _fee;
		emit SetFee(fee);
	}

	/// @notice The item making stuff

	/// @notice The create item function
	function newItem(
		uint256 _price,
		uint256 _deposit,
		bytes32 _metadata
	) public payable tokenPayable returns (uint256 id) {
		unchecked {
			id = itemId++;
		}

		// if deal already exists don't allow to overwrite it
		require(items[id].status == Status.None, 'ITEM_ALREADY_EXISTS');

		// fund this deal
		uint256 totalValue = _price + fee / 2;

		// @dev The Seeker transfers SWT to the marketplace contract
		transferFromSender(address(this), totalValue);

		// @dev The Seeker pays half of the fee to the Maintainer
		transfer(payoutAddress, fee / 2);

		// Seeker rep (cache to save an external call)
		uint256 rep = seekerRep.balanceOf(msg.sender);

		// if it's funded - fill in the details
		items[id] = Item(
			Status.Open,
			fee,
			_price,
			_deposit,
			0,
			rep,
			address(0),
			msg.sender,
			_metadata
		);

		emit NewItem(
			msg.sender,
			id,
			_metadata,
			_price,
			_deposit,
			fee,
			rep,
			block.timestamp
		);
	}

	function signatureKey(
		uint8 v,
		bytes32 r,
		bytes32 s
	) private pure returns (bytes memory signature) {
		signature = new bytes(65);
		assembly {
			mstore(add(signature, 0x20), r)
			mstore(add(signature, 0x40), s)
			mstore8(add(signature, 0x60), v)
		}
	}

	function invalidateSignature(
		uint256 id,
		address provider,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public {
		// Check the seeker's signature
		verifyFundItemSignature(msg.sender, provider, id, v, r, s);

		// Save it to storage
		invalidatedSignatures[signatureKey(v, r, s)] = true;
	}

	/// @notice Provider has to fund the deal
	function fundItem(
		uint256 id,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public payable tokenPayable {
		Item storage item = items[id];

		/// @dev make sure the signature wasn't invalidated
		require(
			!invalidatedSignatures[signatureKey(v, r, s)],
			'SIGNATURE_INVALIDATED'
		);

		/// @dev only allow open deals to be funded
		require(item.status == Status.Open, 'ITEM_NOT_OPEN');

		// Check the seeker's signature
		verifyFundItemSignature(item.seekerAddress, msg.sender, id, v, r, s);

		/// @dev put the tokens from the provider on the deal
		uint256 totalValue = item.deposit + item.fee / 2;
		transferFromSender(address(this), totalValue);

		// @dev The Seeker pays half of the fee to the Maintainer
		transfer(payoutAddress, item.fee / 2);

		/// @dev fill in the address of the provider (to payout the deal later on)
		item.providerAddress = msg.sender;
		item.providerRep = providerRep.balanceOf(msg.sender);
		item.status = Status.Funded;

		emit FundItem(item.providerAddress, id);
		emit ItemStatusChange(id, Status.Funded);
	}

	/// @notice The payout function can only be called by the deal owner.
	function payoutItem(uint256 _id) public {
		Item storage item = items[_id];

		/// @dev Only Seeker can payout
		require(item.seekerAddress == msg.sender, 'UNAUTHORIZED');

		/// @dev you can only payout open deals
		require(item.status == Status.Funded, 'DEAL_NOT_FUNDED');

		/// @dev pay out the provider
		transfer(item.providerAddress, item.price + item.deposit);

		/// @dev mint REP for Provider
		providerRep.mint(item.providerAddress, 5);

		/// @dev mint REP for Seeker
		seekerRep.mint(item.seekerAddress, 5);

		/// @dev mark the deal as done
		item.status = Status.Done;
		emit ItemStatusChange(_id, Status.Done);
	}

	/// @notice The Cancel Item Function
	/// @notice Half of the fee is sent to PayoutAddress
	function cancelItem(uint256 _id) public {
		Item storage item = items[_id];
		require(item.status == Status.Open, 'DEAL_NOT_OPEN');
		require(item.seekerAddress == msg.sender, 'UNAUTHORIZED');

		transfer(item.seekerAddress, item.price);

		item.status = Status.Cancelled;
		emit ItemStatusChange(_id, Status.Cancelled);
	}

	/// @notice The Dispute Item Function
	/// @notice The Seeker or Provider can dispute an item, only the Maintainer can resolve it.
	function disputeItem(uint256 _id) public {
		Item storage item = items[_id];
		require(item.status == Status.Funded, 'DEAL_NOT_FUNDED');
		require(
			item.providerAddress == msg.sender || item.seekerAddress == msg.sender,
			'UNAUTHORIZED'
		);

		/// @dev Set itemStatus to Disputed
		item.status = Status.Disputed;
		emit ItemStatusChange(_id, Status.Disputed);
	}

	/// @notice The Resolve Item Function ♡
	/// @notice The Maintainer resolves the disputed item.
	function resolveItem(uint256 _id, uint256 _seekerAmount) public {
		Item storage item = items[_id];
		require(msg.sender == payoutAddress, 'UNAUTHORIZED');
		require(item.status == Status.Disputed, 'DEAL_NOT_DISPUTED');

		transfer(item.seekerAddress, _seekerAmount);
		transfer(item.providerAddress, item.price + item.deposit - _seekerAmount);

		item.status = Status.Resolved;
		emit ItemStatusChange(_id, Status.Resolved);
	}

	// EIP-712
	function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
		return
			block.chainid == INITIAL_CHAIN_ID
				? INITIAL_DOMAIN_SEPARATOR
				: computeDomainSeparator();
	}

	function computeDomainSeparator() internal view virtual returns (bytes32) {
		return
			keccak256(
				abi.encode(
					keccak256(
						'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
					),
					keccak256(bytes(name)),
					keccak256('1'),
					block.chainid,
					address(this)
				)
			);
	}

	function verifyFundItemSignature(
		address seeker,
		address provider,
		uint256 item,
		uint8 v,
		bytes32 r,
		bytes32 s
	) internal view {
		require(
			uint256(s) <=
				0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
			'INVALID_SIGNATURE_S'
		);

		address recoveredAddress = ecrecover(
			keccak256(
				abi.encodePacked(
					'\x19\x01',
					DOMAIN_SEPARATOR(),
					keccak256(
						abi.encode(
							keccak256(
								'PermitProvider(address seeker,address provider,uint256 item)'
							),
							seeker,
							provider,
							item
						)
					)
				)
			),
			v,
			r,
			s
		);

		require(recoveredAddress == seeker, 'INVALID_SIGNER');
	}

	function transfer(address to, uint256 amount) private {
		if (token == ERC20(address(0))) {
			SafeTransferLib.safeTransferETH(to, amount);
		} else {
			SafeTransferLib.safeTransfer(token, to, amount);
		}
	}

	/// @dev this can only be used once per function with the total msg.value amount
	function transferFromSender(address to, uint256 amount) private {
		if (token == ERC20(address(0))) {
			require(msg.value == amount, 'WRONG_VALUE');
		} else {
			SafeTransferLib.safeTransferFrom(token, msg.sender, to, amount);
		}
	}

	modifier tokenPayable() {
		if (token != ERC20(address(0))) {
			require(msg.value == 0, 'VALUE_NOT_ZERO');
		}
		_;
	}
}

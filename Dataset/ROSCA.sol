pragma solidity ^0.8.25;

import "./deps/ERC20TokenInterface.sol";
import "./deps/SafeMath.sol";

/**
 * @title ROSCA on a blockchain.
 *
 * A ROSCA (Rotating and Savings Credit Association) is an agreement between
 * trusted friends to contribute funds on a periodic basis to a "pot", and in
 * each round one of the participants receives the pot (termed "winner").
 * The winner is selected as the person who makes the lowest bid in that round
 * among those who have not won a bid before.
 * The discount (gap between bid and total round contributions) is dispersed
 * evenly between the participants.
 *
 * Supports ETH and ERC20-compliant tokens.
 */
contract ROSCA {

  uint16 public constant CONTRACT_VERSION  = 3;
  ////////////
  // CONSTANTS
  ////////////
  // Maximum fee (in 1/1000s) from dispersements that is shared between foreperson and other stakeholders..
  uint16 constant internal MAX_FEE_IN_THOUSANDTHS = 20;

  // Start time of the ROSCA must be not more than this much time ago when the ROSCA is created
  // This is to prevent accidental or malicious deployment of ROSCAs that are supposedly
  // already in round number X > 1 and participants are supposedly delinquent.
  uint32 constant internal MAXIMUM_TIME_PAST_SINCE_ROSCA_START_SECS = 900;  // 15 minutes

  // the winning bid must be at least this much of the maximum (aka default) pot value
  uint8 constant internal MIN_DISTRIBUTION_PERCENT = 65;

  // Every new bid has to be at most this much of the previous lowest bid
  uint8 constant internal MAX_NEXT_BID_RATIO = 98;

  // WeTrust's account from which Escape Hatch can be enabled.
  address constant internal ESCAPE_HATCH_ENABLER = 0x5bb8D0DfdAf3a03cF51F9c8623C160a4c021E522;

  /////////
  // EVENTS
  /////////
  event LogContributionMade(address indexed user, uint256 amount, uint256 currentRound);
  event LogStartOfRound(uint256 currentRound);
  event LogBidSurpassed(uint256 prevBid, address indexed prevWinnerAddress, uint256 currentRound);
  event LogNewLowestBid(uint256 bid, address indexed winnerAddress, uint256 currentRound);
  event LogRoundFundsReleased(address indexed winnerAddress, uint256 amount, uint256 roundDiscount, uint256 currentRound);
  event LogFundsWithdrawal(address indexed user, uint256 amount, uint256 currentRound);
  // Fired when withdrawer is entitled for a larger amount than the contract
  // actually holds (excluding fees). A LogFundsWithdrawal will follow
  // this event with the actual amount released, if send() is successful.
  event LogCannotWithdrawFully(address indexed user, uint256 creditAmount, uint256 currentRound);
  event LogUnsuccessfulBid(address indexed bidder, uint256 bid, uint256 lowestBid, uint256 currentRound);
  event LogEndOfROSCA();
  event LogForepersonSurplusWithdrawal(uint256 amount);
  event LogFeesWithdrawal(uint256 amount);

  // Escape hatch related events.
  event LogEscapeHatchEnabled();
  event LogEscapeHatchActivated();
  event LogEmergencyWithdrawalPerformed(uint256 fundsDispersed, uint256 currentRound);

  ////////////////////
  // STORAGE VARIABLES
  ////////////////////

  // ROSCA parameters
  uint256 internal roundPeriodInSecs;
  uint16 internal serviceFeeInThousandths;
  uint16 public currentRound = 1;  // rosca is started the moment it is created
  address internal foreperson;
  uint128 internal contributionSize;
  uint256 internal startTime;
  ERC20TokenInterface public tokenContract;  // public - allow easy verification of token contract.

  // ROSCA state
  // Currently, we support three different types of ROSCA
  // 0 : ROSCA where lowest bidder wins (Bidding ROSCA)
  // 1 : ROSCA where winners are chosen at random (random Selection ROSCA)
  // 2 : ROSCA where winners are selected through a ordered list (pre-determined ROSCA)
  enum typesOfROSCA { BIDDING_ROSCA, RANDOM_SELECTION_ROSCA, PRE_DETERMINED_ROSCA }
  typesOfROSCA roscaType;
  bool public endOfROSCA = false;
  bool public forepersonSurplusCollected = false;
  // A discount is the difference between a winning bid and the pot value. totalDiscounts is the amount
  // of discounts accumulated so far
  uint256 public totalDiscounts = 0;

  // Amount of fees reserved in the contract for fees.
  uint256 public totalFees = 0;

  // Round state variables
  uint256 public lowestBid = 0;
  address public winnerAddress = 0;  // bidder who bid the lowest so far

  mapping(address => User) internal members;
  address[] public membersAddresses;  // for iterating through members' addresses

  // Other state
  // An escape hatch is used in case a major vulnerability is discovered in the contract code.
  // The following procedure is then put into action:
  // 1. WeTrust sends a transaction to make escapeHatchEnabled true.
  // 2. foreperson is notified and can decide to activate the escapeHatch.
  // 3. If escape hatch is activated, no contributions and/or withdrawals are allowed. The foreperson
  //    may call withdraw() to withdraw all of the contract's funds and then disperse them offline
  //    among the participants.
  bool public escapeHatchEnabled = false;
  bool public escapeHatchActive = false;
  bool private reentrancyLock = false;

  struct User {
    uint256 credit;  // amount of funds user has contributed - winnings (not including discounts) so far
    bool debt; // true if user won the pot while not in good standing and is still not in good standing
    bool paid; // yes if the member had won a Round
    bool alive; // needed to check if a member is indeed a member
  }

  ////////////
  // MODIFIERS
  ////////////
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

  modifier onlyNonZeroAddress(address toCheck) {
    require(toCheck != address(0));
    _;
  }

  modifier onlyFromMember {
    require(members[msg.sender].alive);
    _;
  }

  modifier onlyFromForeperson {
    require(msg.sender == foreperson);
    _;
  }

  modifier onlyIfRoscaNotEnded {
    require(!endOfROSCA);
    _;
  }

  modifier onlyIfRoscaEnded {
    require(endOfROSCA);
    _;
  }

  modifier onlyIfEscapeHatchActive {
    require(escapeHatchActive);
    _;
  }

  modifier onlyIfEscapeHatchInactive {
    require(!escapeHatchActive);
    _;
  }

  modifier onlyBIDDING_ROSCA {
    require(roscaType == typesOfROSCA.BIDDING_ROSCA);
    _;
  }

  modifier onlyFromEscapeHatchEnabler {
    require(msg.sender == ESCAPE_HATCH_ENABLER);
    _;
  }

  ////////////
  // FUNCTIONS
  ////////////

  /**
    * @dev Creates a new ROSCA and initializes the necessary variables. ROSCA starts after startTime.
    * Creator of the contract becomes foreperson but not a participant (unless creator's address
    *   is included in members_ parameter).
    *
    * If erc20TokenContract is 0, ETH is taken to be the currency of this ROSCA. Otherwise, this
    * contract assumes `erc20tokenContract` specifies an ERC20-compliant token contract.
    * Note it's the creator's responsibility to check that the provided contract is ERC20 compliant and that
    * it's safe to use.
    */
  function ROSCA(
      ERC20TokenInterface erc20tokenContract,  // pass 0 to use ETH
      typesOfROSCA roscaType_,
      uint256 roundPeriodInSecs_,
      uint128 contributionSize_,
      uint256 startTime_,
      address[] members_,
      uint16 serviceFeeInThousandths_) {
    require(roundPeriodInSecs_ != 0 &&
      startTime_ >= SafeMath.sub(now, MAXIMUM_TIME_PAST_SINCE_ROSCA_START_SECS) &&
      serviceFeeInThousandths_ <= MAX_FEE_IN_THOUSANDTHS &&
      members_.length > 1 && members_.length <= 256); // member count must be 1 < x <= 256

    roundPeriodInSecs = roundPeriodInSecs_;
    contributionSize = contributionSize_;
    startTime = startTime_;
    roscaType = roscaType_;
    tokenContract = erc20tokenContract;
    serviceFeeInThousandths = serviceFeeInThousandths_;

    foreperson = msg.sender;

    for (uint8 i = 0; i < members_.length; i++) {
      addMember(members_[i]);
    }

    require(members[msg.sender].alive);

    LogStartOfRound(currentRound);
  }

  function addMember(address newMember) onlyNonZeroAddress(newMember) internal {
    require(!members[newMember].alive);  // already registered

    members[newMember] = User({paid: false , credit: 0, alive: true, debt: false});
    membersAddresses.push(newMember);
  }

  /**
    * @dev Calculates the winner of the current round's pot, and credits her.
    * If there were no bids during the round, winner is selected semi-randomly.
    * Priority is given to non-delinquent participants.
    */
  function startRound() onlyIfRoscaNotEnded external {
    uint256 roundStartTime = SafeMath.add(startTime, (SafeMath.mul(currentRound, roundPeriodInSecs)));
    require(now >= roundStartTime ); // too early to start a new round.

    if (currentRound != 0) {
      cleanUpPreviousRound();
    }
    if (currentRound < membersAddresses.length) {
      lowestBid = 0;
      winnerAddress = 0;
      currentRound++;
      LogStartOfRound(currentRound);
    } else {
        endOfROSCA = true;
        LogEndOfROSCA();
    }
  }

  /**
   * @dev determine the winner based on the bid, or if no bids were place, find a random winner and credit the
   * user with winnings
   */
  function cleanUpPreviousRound() internal {
    // for pre-ordered ROSCA, pick the next person in the list (delinquent or not)
    if (roscaType == typesOfROSCA.PRE_DETERMINED_ROSCA) {
      winnerAddress = membersAddresses[currentRound - 1];
    } else {
      // We keep the unpaid participants at positions [0..num_participants - current_round) so that we can uniformly select
      // among them (if we didn't do that and there were a few consecutive paid participants, we'll be more likely to select the
      // next unpaid member).
      swapWinner();
    }

    creditWinner();
    recalculateTotalFees();
  }
  /**
   * @dev update the winner's credit with the winning Bid amount or the default PotSize if there were no bid and
   * roundDiscount is added to totalDiscounts
   */
  function creditWinner() internal {
    if (lowestBid == 0) {
      lowestBid = potSize();
    }
    uint256 currentRoundTotalDiscounts = removeFees(potSize() - lowestBid);
    uint256 roundDiscount = currentRoundTotalDiscounts / membersAddresses.length;
    totalDiscounts += currentRoundTotalDiscounts;
    members[winnerAddress].credit += removeFees(lowestBid);
    members[winnerAddress].paid = true;
    LogRoundFundsReleased(winnerAddress, lowestBid, roundDiscount, currentRound);
  }

  /**
   * @dev we choose a winner base current timestamp, giving priority to members in good standing.
   * this is a non-Issue because by nature of ROSCA, each member can only win once
   * @return uint256
   */
  function findSemiRandomWinner(uint16 numUnpaidParticipants) internal returns (uint256) {
    address delinquentWinner = 0x0;
    uint256 winnerIndex;
    // There was no bid in this round. Find an unpaid address for this epoch.
    // Give priority to members in good standing (not delinquent).
    // Note this randomness does not require high security, that's why we feel ok with using the block's timestamp.
    // Everyone will be paid out eventually.
    uint256 semi_random = now % numUnpaidParticipants;
    for (uint16 i = 0; i < numUnpaidParticipants; i++) {
      uint256 index = (semi_random + i) % numUnpaidParticipants;
      address candidate = membersAddresses[index];
      if (!members[candidate].paid) {
        winnerIndex = index;
        if (userTotalCredit(candidate) >= requiredContribution()) {
          // We found a non-delinquent winner.
          winnerAddress = candidate;
          break;
        }
        delinquentWinner = candidate;
      }
    }
    if (winnerAddress == 0) {  // we did not find any non-delinquent winner.
      // Perform some basic sanity checks.
      assert(delinquentWinner != 0 && !members[delinquentWinner].paid);
      winnerAddress = delinquentWinner;
      // Set the flag to true so we know this user cannot withdraw until debt has been paid.
      members[winnerAddress].debt = true;
    }
    // Set lowestBid to the right value since there was no winning bid.
    lowestBid = potSize();
    return winnerIndex;
  }

  /**
   * @dev Recalculates that total fees that should be allocated in the contract.
   */
  function recalculateTotalFees() internal {
    // Start with the max theoretical fees if no one was delinquent, and
    // reduce funds not actually contributed because of delinquencies.
    uint256 grossTotalFees = SafeMath.mul(requiredContribution(), membersAddresses.length);

    for (uint16 j = 0; j < membersAddresses.length; j++) {
      User memory member = members[membersAddresses[j]];
      uint256 credit = userTotalCredit(membersAddresses[j]);
      uint256 debit = requiredContribution();
      if (member.debt) {
        // As a delinquent member won, we'll reduce the funds subject to fees by the default pot they must have won (since
        // they could not bid), to correctly calculate their delinquency.
        debit = SafeMath.add(debit, removeFees(potSize()));
      }
      if (credit < debit) {
        grossTotalFees = SafeMath.sub(grossTotalFees, (debit - credit));
      }
    }

    totalFees = SafeMath.mul(grossTotalFees, serviceFeeInThousandths) / 1000;
  }

  /**
   * @dev Swaps membersAddresses[winnerIndex] with membersAddresses[indexToSwap]. However,
   * if winner was selected through a bid, winnerIndex was not set, and we find it first.
   */
  function swapWinner() internal {
    uint256 winnerIndex;
    uint16 numUnpaidParticipants = uint16(membersAddresses.length) - (currentRound - 1);
    uint16 indexToSwap = numUnpaidParticipants - 1;

    if (winnerAddress == 0) {
      // there are no bids this round, so find a random winner
      winnerIndex = findSemiRandomWinner(numUnpaidParticipants);
    } else {
      // Since winner was selected through a bid, we were not able to set winnerIndex, so search
      // for the winner among the unpaid participants.
      for (uint16 i = 0; i <= indexToSwap; i++) {
        if (membersAddresses[i] == winnerAddress) {
          winnerIndex = i;
          break;
        }
      }
    }
    // We now want to swap winnerIndex with indexToSwap, but we already know membersAddresses[winnerIndex] == winnerAddress.
    membersAddresses[winnerIndex] = membersAddresses[indexToSwap];
    membersAddresses[indexToSwap] = winnerAddress;
  }

  /**
   * @dev Calculates the specified amount net amount after fees.
   * @return uint256
   */
  function removeFees(uint256 amount) internal constant returns (uint256) {
    // First multiply to reduce roundoff errors.
    return SafeMath.mul(amount, (1000 - serviceFeeInThousandths)) / 1000;
  }

  /**
   * @dev Validates a non-zero contribution from msg.sender and returns
   * the amount.
   * @return uint256
   */
  function validateAndReturnContribution() internal returns (uint256) {  // dontMakePublic
    bool isEthRosca = (tokenContract == address(0));
    require(isEthRosca || msg.value <= 0);  // token ROSCAs should not accept ETH

    uint256 value = (isEthRosca ? msg.value : tokenContract.allowance(msg.sender, address(this)));
    require(value != 0);

    if (isEthRosca) {
      return value;
    }
    require(tokenContract.transferFrom(msg.sender, address(this), value));
    return value;
  }

  /**
   * @dev Processes a periodic contribution. msg.sender must be one of the participants and will thus
   * identify the contributor.
   *
   * Any excess funds are withdrawable through withdraw() without fee.
   */
  function contribute() payable onlyFromMember onlyIfRoscaNotEnded onlyIfEscapeHatchInactive external {
    User storage member = members[msg.sender];
    uint256 value = validateAndReturnContribution();
    member.credit = SafeMath.add(member.credit, value);
    if (member.debt) {
      // Check if user comes out of debt. We know they won an entire pot as they could not bid,
      // so we check whether their credit w/o that winning is non-delinquent.
      // check that credit must defaultPot (when debt is set to true, defaultPot was added to credit as winnings) +
      // currentRound in order to be out of debt
      if (SafeMath.sub(userTotalCredit(msg.sender), removeFees(potSize())) >= requiredContribution()) {
          member.debt = false;
      }
    }

    LogContributionMade(msg.sender, value, currentRound);
  }

  /**
   * @dev Registers a bid from msg.sender. Participant should call this method
   * only if all of the following holds for her:
   * + Never won a round.
   * + Is in good standing (i.e. actual contributions, including this round's,
   *   plus any past earned discounts are together greater than required contributions).
   * + New bid is lower than the lowest bid so far.
   * @param bid The Bid amount to place in Wei
   */
  function bid(uint256 bid) onlyFromMember onlyIfRoscaNotEnded onlyIfEscapeHatchInactive onlyBIDDING_ROSCA external {
    require(!members[msg.sender].paid  &&
        currentRound != 0 &&  // ROSCA hasn't started yet
        // participant not in good standing
        userTotalCredit(msg.sender) >= requiredContribution() &&
        // bid is less than minimum allowed
        bid >= SafeMath.mul(potSize(), MIN_DISTRIBUTION_PERCENT) / 100);

    // If winnerAddress is 0, this is the first bid, hence allow full pot.
    // Otherwise, make sure bid is low enough compared to previous bid.
    uint256 maxAllowedBid = winnerAddress == 0
        ? potSize()
        : SafeMath.mul(lowestBid, MAX_NEXT_BID_RATIO) / 100;
    if (bid > maxAllowedBid) {
      // We don't throw as this may be hard for the frontend to predict on the
      // one hand because someone else might have bid at the same time,
      // and we'd like to avoid wasting the caller's gas.
      LogUnsuccessfulBid(msg.sender, bid, lowestBid, currentRound);
      return;
    }
    if (winnerAddress != 0) {
      LogBidSurpassed(lowestBid, winnerAddress, currentRound);
    }

    lowestBid = bid;
    winnerAddress = msg.sender;
    LogNewLowestBid(lowestBid, winnerAddress, currentRound);
  }

  // Sends funds (either ETH or tokens) to msg.sender. Returns whether successful.
  function sendFundsToMsgSender(uint256 value) internal returns (bool) {
    bool isEthRosca = (tokenContract == address(0));
    if (isEthRosca) {
      return msg.sender.send(value);
    }
    return tokenContract.transfer(msg.sender, value);
  }

  /**
   * @dev Withdraws available funds for msg.sender.
   * @return success False if the transfer fails
   */
  function withdraw() onlyFromMember onlyIfEscapeHatchInactive nonReentrant external returns(bool success) {
    require (!members[msg.sender].debt || endOfROSCA); // delinquent winners need to first pay their debt

    uint256 totalCredit = userTotalCredit(msg.sender);

    uint256 totalDebit = members[msg.sender].debt
        ? removeFees(potSize())  // this must be end of rosca
        : requiredContribution();
    require(totalDebit < totalCredit);  // nothing to withdraw

    uint256 amountToWithdraw = SafeMath.sub(totalCredit, totalDebit);
    uint256 amountAvailable = SafeMath.sub(getBalance(), totalFees);

    if (amountAvailable < amountToWithdraw) {
      // This may happen if some participants are delinquent.
      LogCannotWithdrawFully(msg.sender, amountToWithdraw, currentRound);
      amountToWithdraw = amountAvailable;
    }
    members[msg.sender].credit -= amountToWithdraw;
    if (!sendFundsToMsgSender(amountToWithdraw)) {   // if the send() fails, restore the allowance
      // No need to call throw here, just reset the amount owing. This may happen
      // for nonmalicious reasons, e.g. the receiving contract running out of gas.
      members[msg.sender].credit += amountToWithdraw;
      return false;
    }
    LogFundsWithdrawal(msg.sender, amountToWithdraw, currentRound);
    return true;
  }

  /**
   * @dev Returns how much a user can withdraw (positive return value),
   * or how much they need to contribute to be in good standing (negative return value)
   * @return int256
   */
  function getParticipantBalance(address user) onlyFromMember external constant returns(int256) {
    int256 totalCredit = int256(userTotalCredit(user));

    // if rosca have ended, we don't need to subtract as totalDebit should equal to default winnings
    if (members[user].debt && !endOfROSCA) {
        totalCredit -= int256(removeFees(potSize()));
    }
    int256 totalDebit = int256(requiredContribution());

    return totalCredit - totalDebit;
  }

  /**
   * @dev Returns the amount of funds this contract holds excluding fees. This is
   * the amount withdrawable by participants.
   * @return uint256
   */
  function getContractNetBalance() external constant returns(uint256) {
    return SafeMath.sub(getBalance(), totalFees);
  }

  /**
   * @dev Returns the balance of this contract, in ETH or the ERC20 token involved.
   * @return uint256
   */
  function getBalance() internal constant returns (uint256) {
    bool isEthRosca = (tokenContract == address(0));

    return isEthRosca ? this.balance : tokenContract.balanceOf(address(this));
  }

  /**
   * @dev Allows the foreperson to retrieve any surplus funds, one roundPeriodInSecs after
   * the end of the ROSCA. Note this does not retrieve the foreperson's fees, which should
   * be retireved by calling endOfROSCARetrieveFees.
   *
   * Note that startRound() must be called first after the last round, as it
   * does the bookeeping of that round.
   */
  function endOfROSCARetrieveSurplus() onlyFromForeperson onlyIfRoscaEnded external {
    uint256 roscaCollectionTime = SafeMath.add(startTime, SafeMath.mul((membersAddresses.length + 1), roundPeriodInSecs));
    require(now >= roscaCollectionTime && !forepersonSurplusCollected);

    forepersonSurplusCollected = true;
    uint256 amountToCollect = SafeMath.sub(getBalance(), totalFees);
    if (!sendFundsToMsgSender(amountToCollect)) {   // if the send() fails, restore the flag
      // No need to call throw here, just reset the amount owing. This may happen
      // for nonmalicious reasons, e.g. the receiving contract running out of gas.
      forepersonSurplusCollected = false;
    } else {
      LogForepersonSurplusWithdrawal(amountToCollect);
    }
  }

  /**
   * @dev Allows the foreperson to extract the fees in the contract. Can be called
   * after the end of the ROSCA.
   *
   * Note that startRound() must be called first after the last round, as it
   * does the bookeeping of that round.
   */
  function endOfROSCARetrieveFees() onlyFromForeperson onlyIfRoscaEnded external {
    uint256 tempTotalFees = totalFees;  // prevent re-entry.
    totalFees = 0;
    if (!sendFundsToMsgSender(tempTotalFees)) {   // if the send() fails, restore totalFees
      // No need to call throw here, just reset the amount owing. This may happen
      // for nonmalicious reasons, e.g. the receiving contract running out of gas.
      totalFees = tempTotalFees;
    } else {
      LogFeesWithdrawal(tempTotalFees);
    }
  }

  /**
   * @dev Allows the Escape Hatch Enabler (controlled by WeTrust) to enable the Escape Hatch in case of
   * emergency (e.g. a major vulnerability found in the contract).
   */
  function enableEscapeHatch() onlyFromEscapeHatchEnabler external {
    escapeHatchEnabled = true;
    LogEscapeHatchEnabled();
  }

  /**
   * @dev Allows the foreperson to active the Escape Hatch after the Enabled enabled it. This will freeze all
   * contributions and withdrawals, and allow the foreperson to retrieve all funds into their own account,
   * to be dispersed offline to the other participants.
   */
  function activateEscapeHatch() onlyFromForeperson external {
    require(escapeHatchEnabled);

    escapeHatchActive = true;
    LogEscapeHatchActivated();
  }

  /**
   * @dev Can only be called by the foreperson after an escape hatch is activated,
   * this sends all the funds to the foreperson by selfdestructing this contract.
   */
  function emergencyWithdrawal() onlyFromForeperson onlyIfEscapeHatchActive external {
    LogEmergencyWithdrawalPerformed(getBalance(), currentRound);
    bool fundsTransferSuccess = false;
    // Send everything, including potential fees, to foreperson to disperse offline to participants.
    bool isEthRosca = (tokenContract == address(0));
    if (!isEthRosca) {
      uint256 balance = tokenContract.balanceOf(address(this));
      fundsTransferSuccess = tokenContract.transfer(foreperson, balance);
    }

    if (fundsTransferSuccess || isEthRosca) {
      selfdestruct(foreperson);
    }
  }

  ////////////////////
  // HELPER FUNCTIONS
  ////////////////////


  /**
   * @dev calculates the user's discount amount from the total discount
   * @return uint256
   */
  function userTotalCredit(address memberAddress) internal constant returns (uint256) {
    uint256 userDiscount = totalDiscounts / membersAddresses.length;

    return SafeMath.add(members[memberAddress].credit, userDiscount);
  }

	/**
   * @dev calculates the default amount user can win in a round
   * @return uint256
   */
  function potSize() internal constant returns (uint256) {
    return SafeMath.mul(contributionSize, membersAddresses.length);
  }

  /**
   * @dev calculates the require amount of contribution for user to be in good standing
   * @return uint256
   */
  function requiredContribution() internal constant returns (uint256) {
    return SafeMath.mul(contributionSize, currentRound);
  }
}

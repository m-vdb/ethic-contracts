contract deductible_backing_car_collision {

  /**
   *   The structs.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#structs
   */

  struct Policy {
    uint policy_id;
    uint year;
    string model;
    uint initial_premium;
    uint initial_deductible;
    // TODO: find how to register dates, probably in seconds since...
    uint registered_date;
  }


  struct Claim {
    uint claim_id;
    address claimer;
    uint amount;
    // TODO: find how to register dates, probably in seconds since...
    uint filing_date;
    uint nb_of_validations;
    bool awarded;
    bool paid;
    uint agreed_amount;
  }


  struct Member {
  	// TODO: see how we manage the fact that the sender of the message
  	// is not always the address we registered, maybe we should pass 
  	// back logged_address all the time
    address beneficiary;
    string name;
    uint amount_contributed;
    uint joining_date;
    // if he has two cars
    uint nb_of_policies;
    // FIXME: rename attribute?
    mapping (uint => Claim) personal_legacy;
    mapping (uint => Policy) member_policies;
    // this is how much token he has, token being our cryptocurrency
    uint token_balance;
    // we create the member but he has to be accepted,
    // first by us, in time by his peers
    bool admitted;
  }


  /**
   *   The storage.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#data-location
   */

  // FIXME: redundant with storage type
  uint nb_members;
  uint id_of_last_claim_settled;  // this is for payments
  // FIXME: find out which storage is better
  mapping (uint => Member) members_by_id;
  mapping (address => Member) members_by_address;
  // will hold the claims
  Claim[] claims_ledger;
  // FIXME: maybe we don't need it, and use a function instead
  // this is just to avoid charging people who have not yet been admitted into the DAO
  uint nb_admitted_members;
  uint nb_registered_policies;

  /**
   *   The contract's functions.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#data-location
   */


  /**
   * Create a new member
   * When he subscribes he does not have any
   * policy underwritten. We provide default
   * values.
   */

  function create_member(string name) {

    var account = msg.sender;
    // FIXME: we need to check if the account exists
    members_by_address[account] = Member({
      beneficiary: account,
      name: name,  // TODO: we'll see if we need this
      amount_contributed: 0,
      joining_date: block.timestamp,  // we date his joining the DAO on the day of the current block
      nb_of_policies: 0, // FIXME: check default value 'if this is too heavy just set to 1 by default'
      token_balance: 0,
      admitted: false  // when he registers he is not admitted yet
    });
  }

  /**
   * Admit a member
   * In the first place, this function should actually only
   * be called by us, once we've done the background check.
   * Maybe later we will have peers invite their friends
   * making this process easier.
   */

  function admit_member(address admitted_address) {
    members_by_address[admitted_address].admitted = true;
    nb_admitted_members++;
  }

  /**
   * Add a policy to a member (the sender)
   */

  function add_policy(uint car_year, string car_model, uint old_premium, uint old_deductible) {
    var member = members_by_address[msg.sender];
    var member_policies = member.member_policies;
    var policy_id = member.nb_of_policies;
    member_policies[policy_id] = Policy({
      policy_id: policy_id,  // FIXME: maybe we want a more global ID ?
      year: car_year,
      model: car_model,
      initial_premium: old_premium,
      initial_deductible: old_deductible,
      registered_date: block.timestamp
    });
    member.nb_of_policies++;
  }

  /**
   * File a claim
   *
   * Later this methode would take the policy
   * as argument, for several policies (cars, home, etc...).
   */

  function claim(uint amount_claimed) {

    claims_ledger[claims_ledger.length] = Claim({
      claim_id: claims_ledger.length,
      claimer: msg.sender,
      amount: amount_claimed,
      filing_date: block.timestamp,
      nb_of_validations: 0,
      awarded: false,
      paid: false,
      agreed_amount: 0
    });
  }

  /**
   * Award a claim
   *
   * This method takes as argument the claim id
   * and the agreed amount.
   */

  function award_claim(uint claim_id, uint agreed_amount) {
    // we set the value agreed by the auditor
    // which can differ downward from the claimed amount
    claims_ledger[claim_id].agreed_amount = agreed_amount;
    // we have to actually take the amount the auditor agreed on
    // not necessarily the amount initially claimed
    send_tokens(msg.sender, agreed_amount);
  }

  /**
   * Send tokens to a member
   *
   * This method takes as argument the claimer
   * and the amount to send
   */

  function send_tokens(address claimer, uint amount) {
    // FIXME: define constant https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#constants
    var adjusted_amount = amount - 250;
    // the token is in dollars, we will also do a simple verification so that
    // if he has claimed more than once he only receives a part of the amount,
    // and only a part of the amount is deducted from the organization's accounts
    // -> @leo what did you mean?
    members_by_address[claimer].token_balance += adjusted_amount;

    // each member of the DAO receives
    for (uint i = 0 ; i < nb_members + 1 ; i++) {
      Member contributor = members_by_id[i];
      if (contributor.admitted = true){
        // nb_admitted_members so we don't charge people who are waiting to be accepted into the DAO
        // -> @leo: you assume here that if a member has two policies, he weighs twice a member that has one?
        contributor.token_balance -= adjusted_amount / nb_admitted_members * contributor.nb_of_policies;
      }
    }
  }

  /**
   * Settle the claims.
   *
   * This method should be called regularly (polling).
   * TODO: figure out how to do that exactly (API, etc...)
   * TODO: make sure the contract has balance
   */

  function settlement() {

    uint i = id_of_last_claim_settled + 1;
    // we have to actually take the amount the auditor agreed on,
    // not necessarily the amount initially claimed
    while (address(this).balance > claims_ledger[i].agreed_amount && i < claims_ledger.length) {
      claims_ledger[i].claimer.send(claims_ledger[i].agreed_amount);
      i++;
    }
  }

  /**
   * FIXME: think of better name? 'make_token_payment' 
   * when a member pays in ether the amount of his tokenbalance, it resets
   */

  function reset_token_balance(address where_to_reset, uint by_how_much) {
    // FIXME: where_to_reset == msg.sender ? how do we call this method
    members_by_address[where_to_reset].token_balance -= by_how_much;
  }

}

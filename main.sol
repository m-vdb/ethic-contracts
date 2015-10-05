contract ethic_main {

  /**
   *   The structs.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#structs
   */

  enum MemberState { Active, Inactive }

  struct Policy {
    uint id;
    uint8 car_year;
    bytes car_make;
    bytes car_model;
    bytes state;  // CA, WA, LA, ...
    uint8 initial_premium;  // stored in cents
    uint8 initial_deductible;  // stored in cents
    // TODO: find how to register dates, probably in seconds since...
    uint registered_at;
  }


  struct Claim {
    uint id;
    address claimer;
    uint amount;  // stored in cents
    // TODO: find how to register dates, probably in seconds since...
    uint filed_at;
    uint nb_of_validations;  // FIXME: what is it for?
    bool awarded;
    bool paid;
    uint agreed_amount;
  }


  struct Member {
  	// TODO: see how we manage the fact that the sender of the message
  	// is not always the address we registered, maybe we should pass 
  	// back logged_address all the time
    address id;
    // holds the state of the member: active/inactive
    MemberState state;
    uint created_at;
    uint amount_contributed;
    // this is how much token he has, token being our cryptocurrency
    uint token_balance;
  }


  /**
   *   The storage.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#data-location
   */

  uint id_of_last_claim_settled;  // this is for payments

  address[] members_addresses;  // FIXME: we need this because we cant iterate over mapping
  mapping (address => Member) public members;
  mapping (address => Policy[]) public policies;
  // will hold the claims
  Claim[] claims_ledger;
  // useful to count only active members when charging people
  uint public nb_active_members;
  uint nb_registered_policies;

  // contructor
  function ethic_main() public {
    id_of_last_claim_settled = 0;
    nb_active_members = 0;
    nb_registered_policies = 0;
  }

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

  function create_member(address addr) {
    // TODO: if (members[addr].id == addr) throw;
    members[addr] = Member(addr, MemberState.Active, block.timestamp, 0, 0);
    members_addresses.length++;
    members_addresses[members_addresses.length - 1] = addr;
    nb_active_members++;
  }


  /**
   * Deactivate a member. In case the member wants to
   * remove his account or is dormant.
   */

  function deactivate_member(address addr) {
    members[addr].state = MemberState.Inactive;
    nb_active_members--;
  }

  function get_number_of_policies(address addr) constant returns (uint){
    return policies[addr].length;
  }

  /**
   * Add a policy to a member (the sender)
   */

  function add_policy(address addr, uint8 car_year, bytes car_make, bytes car_model, uint8 old_premium, uint8 old_deductible) {
    var member = members[addr];
    // TODO: if (member.id != addr) throw;
    var member_policies = policies[addr];
    var policy_id = member_policies.length;
    member_policies[policy_id] = Policy({
      id: policy_id,  // FIXME: maybe we want a more global ID ?
      car_year: car_year,
      car_make: car_make,
      car_model: car_model,
      state: "CA",  // this is hardcoded for now
      initial_premium: old_premium,
      initial_deductible: old_deductible,
      registered_at: block.timestamp
    });
  }

  /**
   * File a claim
   *
   * Later this methode would take the policy
   * as argument, for several policies (cars, home, etc...).
   */

  function claim(uint amount_claimed) returns (uint) {

    uint claim_id = claims_ledger.length;
    claims_ledger[claim_id] = Claim({
      id: claim_id,
      claimer: msg.sender,
      amount: amount_claimed,
      filed_at: block.timestamp,
      nb_of_validations: 0,
      awarded: false,
      paid: false,
      agreed_amount: 0
    });
    return claim_id;
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

  // TODO: add policy type as argument
  function send_tokens(address claimer, uint amount) {
    // FIXME: define constant https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#constants
    var adjusted_amount = amount - 250;
    // the token is in dollars, we will also do a simple verification so that
    // if he has claimed more than once he only receives a part of the amount,
    // and only a part of the amount is deducted from the organization's accounts
    // -> @leo what did you mean?
    members[claimer].token_balance += adjusted_amount;

    // each member of the DAO receives
    for (uint i = 0 ; i < members_addresses.length + 1 ; i++) {
      address member_address = members_addresses[i];
      Member contributor = members[member_address];
      // TODO?: the filtering is made among the members that own the
      // same type of policy (California, car, deductible 2500)
      if (contributor.state == MemberState.Active && contributor.id != claimer){
        // nb_active_members so we don't charge people who are waiting to be accepted into the DAO
        // -> @leo: you assume here that if a member has two policies, he weighs twice a member that has one?
        // nb_active_members - 1, 1 being the claimer
        contributor.token_balance -= adjusted_amount / (nb_active_members - 1) * get_number_of_policies(contributor.id);
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
      // TODO: we want to set the "paid" attribute to true
    }
  }

  /**
   * FIXME: think of better name? 'make_token_payment' 
   * when a member pays in ether the amount of his tokenbalance, it resets
   */

  function reset_token_balance(address where_to_reset, uint by_how_much) {
    // FIXME: where_to_reset == msg.sender ? how do we call this method
    members[where_to_reset].token_balance -= by_how_much;
  }
}

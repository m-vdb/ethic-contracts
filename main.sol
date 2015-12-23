contract ethic_main {

  /**
   *   The structs.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#structs
   */

  enum MemberState { Active, Inactive }

  struct Claim {
    uint id;
    address claimer;
    uint amount;  // stored in cents
    bool paid;
    uint received_at;
  }


  struct Member {
    address id;
    // holds the state of the member: active/inactive
    MemberState state;
    uint created_at;
    uint amount_contributed;
    uint8 policy_count;
    // this is how much token he has, token being our cryptocurrency
    int token_balance;
  }


  /**
   *   The storage.
   *   See https://github.com/ethereum/wiki/wiki/Solidity-Tutorial#data-location
   */

  uint id_of_last_claim_settled;  // this is for payments

  address[] members_addresses;  // FIXME: we need this because we cant iterate over mapping
  mapping (address => Member) public members;
  // will hold the claims
  Claim[] claims_ledger;

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

  function create_member(address addr, uint8 policy_count) {
    members[addr] = Member(addr, MemberState.Active, block.timestamp, 0, policy_count, 0);
    members_addresses.length++;
    members_addresses[members_addresses.length - 1] = addr;
    nb_registered_policies += policy_count;
  }


  /**
   * Deactivate a member. In case the member wants to
   * remove his account or is dormant.
   */

  function deactivate_member(address addr) {
    var member = members[addr];
    member.state = MemberState.Inactive;
    nb_registered_policies -= member.policy_count;
  }

  /**
   * Add a policy to a member
   */

  function add_policy(address addr) {
    var member = members[addr];
    member.policy_count++;
    nb_registered_policies++;
  }

  /**
   * Remove a policy from a member
   */

  function remove_policy(address addr) {
    var member = members[addr];
    // TODO: if (member.id != addr) throw;
    member.policy_count--;
    nb_registered_policies--;
  }

  /**
   * File a claim
   *
   * We add the claim to the claim ledger. When the
   * claim arrives here, it means that it was awarded,
   * but not paid yet. We save the address of the claimer
   * as well as the claim amount.
   */

  function claim(address addr, uint claim_id, uint amount) {
    claims_ledger.length++;
    claims_ledger[claims_ledger.length - 1] = Claim({
      id: claim_id,
      claimer: addr,
      amount: amount,
      received_at: block.timestamp,
      paid: false
    });
  }

  /**
   * Send tokens to a member
   *
   * This method takes as argument the claimer
   * and the amount to send
   */

  function send_tokens(address claimer_addr, uint _amount) {
    var claimer = members[claimer_addr];
    var amount = int(_amount);
    claimer.token_balance += int(amount);
    uint total_nb_policies = nb_registered_policies - claimer.policy_count;

    // each member of the DAO receives
    for (uint i = 0 ; i < members_addresses.length + 1 ; i++) {
      address member_address = members_addresses[i];
      Member contributor = members[member_address];
      // we don't charge the claimer and the amount removed from the
      // token balance is weighed with the number of policies of the member
      if (contributor.state == MemberState.Active && contributor.id != claimer.id){
        contributor.token_balance -= amount / int(total_nb_policies * contributor.policy_count);
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
    while (address(this).balance > claims_ledger[i].amount && i < claims_ledger.length) {
      var claim = claims_ledger[i];
      send_tokens(claims_ledger[i].claimer, claims_ledger[i].amount);
      i++;
      claim.paid = true;
    }
  }

  /**
   * FIXME: think of better name? 'make_token_payment' 
   * when a member pays in ether the amount of his tokenbalance, it resets
   */

  function reset_token_balance(address where_to_reset, int by_how_much) {
    // FIXME: where_to_reset == msg.sender ? how do we call this method
    members[where_to_reset].token_balance -= by_how_much;
  }
}

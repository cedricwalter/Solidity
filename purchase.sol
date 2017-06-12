pragma solidity ^0.4.11;


contract Purchase {
    uint public value; // Of item

    address public seller;
    address public buyer;

    enum State {Created, Locked, Inactive}

    State public state;

    function Purchase() payable {
        seller = msg.sender;
        value = msg.value / 2;
        require((2 * value) == msg.value);
    }

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    event Aborted();

    event PurchaseConfirmed();

    event ItemReceived();

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    function abort()
      onlySeller
      inState(State.Created)
    {
        Aborted();
        state = State.Inactive;
        seller.transfer(this.balance);
    }

    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * value` ether.
    /// The ether will be locked until confirmReceived
    /// is called.
    function confirmPurchase()
      inState(State.Created)
      condition(msg.value == (2 * value))
    payable
    {
        PurchaseConfirmed();
        buyer = msg.sender;
        state = State.Locked;
    }

    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    function confirmReceived()
      onlyBuyer
      inState(State.Locked)
    {
        ItemReceived();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Inactive;

        // TODO NOTE: This actually allows both the buyer and the seller to
        // block the refund

        // the withdraw pattern should be used.
        // 1. If the recipient is a contract, it causes its fallback function to be executed which can, in turn,
        //    call back the sending contract.
        // 2. Sending Ether can fail due to the call depth going above 1024. Since the caller is in total control of
        //    the call depth, they can force the transfer to fail; take this possibility into account or use send and
        //    make sure to always check its return value. Better yet, write your contract using a pattern where the
        //    recipient can withdraw Ether instead.
        // 3. Sending Ether can also fail because the execution of the recipient contract requires more than the allotted
        //    amount of gas (explicitly by using require, assert, revert, throw or because the operation is just too
        //    expensive) - it “runs out of gas” (OOG). If you use transfer or send with a return value check, this might
        //    provide a means for the recipient to block progress in the sending contract.
        buyer.transfer(value);
        seller.transfer(this.balance);
    }

}


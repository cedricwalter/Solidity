pragma solidity ^0.4.11;

/**
 * Copyright (c) 2017-2017 by Cédric Walter - www.cedricwalter.com
 *
 * Unicorns-Coin is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * IT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// add support for centralized administrator
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;

        // Placeholder for function code with modifier onlyOwner
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

//Unicorns is yet another digital token :-)
contract Unicorns is owned {

    string public name = "unicorns";

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    // Contract owner can freeze or unfreeze assets
    mapping (address => bool) public frozenAccount;


    mapping (address => bool) public approvedAccount;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Unicorns(uint256 initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol, address centralMinter) {
        totalSupply = initialSupply;

        // Give the creator all initial tokens
        balanceOf[msg.sender] = initialSupply;

        // Set the name for display purposes
        name = tokenName;

        // Set the symbol for display purposes
        symbol = tokenSymbol;

        // Amount of decimals for display purposes
        decimals = decimalUnits;

        if (centralMinter != 0) {
            // Set the owner of the contract at startup
            owner = centralMinter;
        }
    }


    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
    event ApprovedAccount(address target);

    // To change the amount of coins in circulation
    function mintToken(address target, uint256 mintedAmount) onlyOwner {

        /* Check for overflows */
        if (balanceOf[target] + mintedAmount < balanceOf[target])
        throw;

        balanceOf[target] += mintedAmount;


        totalSupply += mintedAmount;

        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function approvedAccount(address target) onlyOwner {
        approvedAccount[target] = freeze;
        ApprovedAccount(target);
    }

    function transfer(address _to, uint256 _value) {
        if (frozenAccount[msg.sender]) throw;

        if (!approvedAccount[msg.sender]) throw;

        /* Check if sender has balance and for overflows */
        if (balanceOf[msg.sender] < _value || balanceOf[_to] + _value < balanceOf[_to])
        throw;

        /* Add and subtract new balances */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        /* Notify anyone listening that this transfer took place */
        Transfer(msg.sender, _to, _value);
    }

}
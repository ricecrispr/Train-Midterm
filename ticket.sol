// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Ticket {
   mapping(address => bool) public hasTicket;
   mapping(address => bool) public hasBoarded;


   // Event to notify that a ticket was claimed
   event TicketClaimed(address indexed user);
   // Event to notify that a ticket was used
   event TicketUsed(address indexed user);


   // Claim a ticket if the user doesn't already have one
   function claimTicket() public {
       require(!hasTicket[msg.sender], "You already have a ticket.");
       require(!hasBoarded[msg.sender], "You already boarded.");
       hasTicket[msg.sender] = true;
       emit TicketClaimed(msg.sender);
   }


   // Use the ticket if the user has one
   function useTicket(address user) external {
       require(hasTicket[user], "User does not have a ticket.");
       require(!hasBoarded[user], "User has already boarded.");
       hasTicket[user] = false;
       hasBoarded[user] = true;
       emit TicketUsed(user);
   }


   // unboard the user
   function unboardUser(address user) external {
       hasBoarded[user] = false;
   }


   // Check if a user has a ticket
   function checkTicket(address user) external view returns (bool) {
       return hasTicket[user];
   }
}



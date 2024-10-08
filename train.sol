// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./Ticket.sol";


contract Train {
   Ticket public ticketContract;
   uint public boardingCount = 0;
   uint public lastDepartureTime = 0;
   uint public constant BOARDING_LIMIT = 3;
   uint public constant TRAIN_RETURN_TIME = 5 minutes; // Cooldown for train to return after departure


   mapping(address => uint) public lastBoardingTime;
   address[] public passengers;


   // Event to notify that the train has left
   event TrainLeft(address[] passengers, uint timestamp);
   // Event to notify that a user boarded the train
   event UserBoarded(address indexed user);


   constructor(address _ticketContractAddress) {
       ticketContract = Ticket(_ticketContractAddress);
   }


   // Check how many users have boarded
   function checkHowManyBoarded() public view returns (uint256) {
       return passengers.length;
   }


   // Board the train if the user has a ticket and the train is not in cooldown period
   function boardTrain() public {
       // Ensure the train has returned (enough time has passed since the last departure)
       require(
           block.timestamp >= lastDepartureTime + TRAIN_RETURN_TIME,
           "Train is not available, it hasn't returned to the station."
       );


       require(ticketContract.checkTicket(msg.sender), "You need a ticket to board.");
       require(passengers.length < BOARDING_LIMIT, "The train is full.");


       // Use the ticket and add the user to the passengers list
       ticketContract.useTicket(msg.sender);
       lastBoardingTime[msg.sender] = block.timestamp;
       passengers.push(msg.sender);
       emit UserBoarded(msg.sender);


       // Check if the train is full and should leave
       if (passengers.length == BOARDING_LIMIT) {
           leaveStation();
       }
   }


   // Internal function for the train to leave the station
   function leaveStation() internal {
       emit TrainLeft(passengers, block.timestamp);
       lastDepartureTime = block.timestamp;
       boardingCount++;


       for(uint8 i = 0; i < passengers.length; i++) {
           ticketContract.unboardUser(passengers[i]);
       }


       // Reset the passengers for the next trip
       delete passengers;
   }


   // Function to check if the train is available for boarding
   function isTrainAvailable() public view returns (bool) {
       // Returns true if the cooldown period for the train's return has passed
       return block.timestamp >= lastDepartureTime + TRAIN_RETURN_TIME;
   }
}



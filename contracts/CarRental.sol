//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CarRental {
    address public owner;
    uint ownerBalance;
    uint public price;
    uint public id = 0;

    constructor(uint _price) {
        owner = msg.sender;
        price = _price;
    }

    modifier isRenter(address walletAddress) {
        require(msg.sender == walletAddress);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    struct Renter {
        address payable walletAddress;
        uint id;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }

    mapping(address => Renter) public renters;

    function addRenter(
        address payable walletAddress,
        bool canRent,
        bool active,
        uint balance,
        uint due,
        uint start,
        uint end
    ) public {
        require(msg.sender != owner, "The owner cannot rent a car");
        id++;
        renters[walletAddress] = Renter(walletAddress, id, canRent, active, balance, due, start, end);
    }

    function getRenterId(address payable walletAddress) public view returns (uint) {
        return renters[walletAddress].id;
    }

    function changePrice(uint newPrice) public onlyOwner {
        require(newPrice > 0, "Price must be greater than zero");
        price = newPrice;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != owner, "The new owner must be different to the orignal owner");
        owner = newOwner;
    }

    // Get Contract Balance

    function balanceOf() public view onlyOwner returns (uint) {
        return address(this).balance;
    }

    function getOwnerBalance() public view onlyOwner returns (uint) {
        return ownerBalance;
    }

    function withdrawOwnerBalance() public payable onlyOwner {
        payable(owner).transfer(ownerBalance);
    }

    function checkOutCar(address walletAddress) public isRenter(walletAddress) {
        require(renters[walletAddress].due == 0, "You have a pending balance.");
        require(renters[walletAddress].canRent == true, "You cannot rent at this time.");
        require(msg.sender != owner, "The owner cannot rent a car.");
        renters[walletAddress].active = false;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    function checkInCar(address walletAddress) public isRenter(walletAddress) {
        require(renters[walletAddress].active == false, "Please check out a car first.");
        require(msg.sender != owner, "The owner cannot rent a car.");
        renters[walletAddress].active = true;
        renters[walletAddress].end = block.timestamp;
        setDue(walletAddress);
    }

    // Get total duration of car use
    function renterTimespan(uint start, uint end) internal pure returns (uint) {
        return end - start;
    }

    function getTotalDuration(address walletAddress) public view isRenter(walletAddress) returns (uint) {
        if (renters[walletAddress].start == 0 || renters[walletAddress].end == 0) {
            return 0;
        } else {
            uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
            uint timespanInMinutes = timespan / 60;
            return timespanInMinutes;
        }
    }

    // Get Renter's balance
    function balanceOfRenter(address walletAddress) public view isRenter(walletAddress) returns (uint) {
        return renters[walletAddress].balance;
    }

    // Set Due amount
    function setDue(address walletAddress) internal {
        uint timespanMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinuteIncrements * price;
    }

    function canRentCar(address walletAddress) public view isRenter(walletAddress) returns (bool) {
        return renters[walletAddress].canRent;
    }

    // Deposit
    function deposit(address walletAddress) public payable isRenter(walletAddress) {
        renters[walletAddress].balance += msg.value;
    }

    // Make Payment
    function makePayment(address walletAddress, uint amount) public isRenter(walletAddress) {
        require(renters[walletAddress].due > 0, "You do not have anything due at this time.");
        require(
            renters[walletAddress].balance > amount,
            "You do not have enough funds to cover payment. Please make a deposit."
        );
        renters[walletAddress].balance -= amount;
        ownerBalance += amount;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

    function getDue(address walletAddress) public view isRenter(walletAddress) returns (uint) {
        return renters[walletAddress].due;
    }

    function getRenter(
        address walletAddress
    ) public view isRenter(walletAddress) returns (uint _id, bool canRent, bool active) {
        _id = renters[walletAddress].id;
        canRent = renters[walletAddress].canRent;
        active = renters[walletAddress].active;
    }

    function renterExists(address walletAddress) public view isRenter(walletAddress) returns (bool) {
        if (renters[walletAddress].walletAddress != address(0)) {
            return true;
        }
        return false;
    }
}

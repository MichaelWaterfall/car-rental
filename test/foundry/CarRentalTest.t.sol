// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "contracts/CarRental.sol";

contract CarRentalTest is Test {
    CarRental public carRental;
    address user = makeAddr("user");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        carRental = new CarRental(1);
    }

    function testAddRenter() public {
        vm.prank(user);
        carRental.addRenter(payable(user), true, false, 1, 0, 0, 0);
        assertEq(carRental.getRenterId(payable(user)), 1);
        vm.prank(user1);
        carRental.addRenter(payable(user1), true, false, 1, 0, 0, 0);
        assertEq(carRental.getRenterId(payable(user1)), 2);
    }

    function testFailAddRenterUsingOwner() public {
        vm.prank(user);
        vm.expectRevert("The owner cannot rent a car");
        carRental.addRenter(payable(user), true, false, 1, 0, 0, 0);
    }

    function testChangePrice() public {
        carRental.changePrice(2);
        assertEq(carRental.price(), 2);
    }

    function testFailChangePrice() public {
        vm.expectRevert("Price must be greater than zero");
        carRental.changePrice(0);
    }

    function testFailChangePriceNotOwner() public {
        vm.prank(user);
        vm.expectRevert("Only the owner can call this function");
        carRental.changePrice(2);
    }

    function testChangeOwner() public {
        carRental.changeOwner(user2);
        assertEq(carRental.owner(), user2);
    }

    function testFailChangeOwnerNotOwner() public {
        vm.prank(user);
        vm.expectRevert(bytes("Only the owner can call this function"));
        carRental.changeOwner(user2);
    }

    function testBalanceOf() public {
        assertEq(carRental.balanceOf(), 0);
    }

    function testGetOwnerBalance() public {
        assertEq(carRental.getOwnerBalance(), 0);
    }

    function testWithdrawOwnerBalance() public {}

    function testCheckOutCar() public {
        vm.prank(user);
        carRental.checkOutCar(user);
    }

    function testCheckInCar() public {}

    function testRenterTimespan() public {}

    function testGetTotalDuration() public {}

    function testBalanceOfRenter() public {
        assertEq(carRental.balanceOfRenter(user), 1);
    }

    function testSetDue() public {}

    function testCanRentCar() public {
        vm.prank(user);
        carRental.addRenter(payable(user), true, false, 1, 0, 0, 0);
        assertEq(carRental.canRentCar(user), true);
    }

    function testDeposit() public {}

    function testMakePayment() public {}

    function testGetDue() public {
        //assertEq(carRental.getRenterId(payable(user)), 1);
    }

    function testGetRenter() public {
        //assertEq(carRental.getRenter(user), (1, true, false));
    }

    function testRenterExists() public {
        vm.prank(user);
        carRental.addRenter(payable(user), true, false, 1, 0, 0, 0);
        assertEq(carRental.renterExists(user), true);
    }
}

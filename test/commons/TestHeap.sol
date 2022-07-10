// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "test/commons/Random.sol";
import "test/commons/IHeapWrapper.sol";
import "forge-std/Test.sol";

abstract contract TestHeap is Test, Random {
    IHeapWrapper wrapper;
    
    address[] ids;

    uint256 n = 50000;
    uint256 maxSortedUsers;

    function setUp() public {}

    function insert() public {
        address id = randomAddress();
        ids.push(id);
        wrapper.insert(id, randomUint256(), maxSortedUsers);
    }

    function remove() public {
        uint256 index = randomUint256(ids.length);
        address toRemove = ids[index];

        wrapper.remove(toRemove, wrapper.getValueOf(toRemove), maxSortedUsers);
        ids[index] = ids[ids.length-1];
        ids.pop();
    }

    function increase() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = wrapper.getValueOf(toUpdate);

        wrapper.increase(
            ids[index],
            formerValue,
            randomUint256(formerValue + (type(uint256).max - formerValue)),
            maxSortedUsers
        );
    }

    function decrease() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = wrapper.getValueOf(toUpdate);

        wrapper.decrease(
            ids[index],
            formerValue,
            randomUint256(formerValue),
            maxSortedUsers
        );
    }

    function testFullHeapSort() public {
        
        maxSortedUsers = n;
        for (uint256 i; i < n;) {
            if (ids.length == 0) insert();
            else {
                uint256 r = randomUint256(5);
                if (r < 2) insert();
                else if (r == 2) remove();
                else if (r == 3) increase();
                else decrease();
            }
            unchecked{++i;}
        }

        uint256 lastValue = type(uint256).max;
        uint256 newValue;
        while ((newValue = wrapper.removeHead(maxSortedUsers)) != 0) {
            require(newValue <= lastValue, "not sorted");
            lastValue = newValue;
        }
    }
}
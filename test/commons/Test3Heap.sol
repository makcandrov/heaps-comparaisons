// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "test/commons/TestHeap.sol";
abstract contract Test3Heap is TestHeap {
    
    function verify3HeapStructure(uint256 size) internal view {
        uint256 firstChildRank;
        uint256 secondChildRank;
        uint256 thidChildRank;
        uint256 initialValue;
        uint256 firstChildValue;
        uint256 secondChildValue;
        uint256 thirdChildValue;
        for (uint256 rank; rank < size / 3; rank++) {
            (, initialValue) = wrapper.accounts(rank);
            firstChildRank = 3 * rank + 1;
            secondChildRank = 3 * rank + 2;
            thidChildRank = 3 * rank + 3;
            if (firstChildRank < size) {
                (, firstChildValue) = wrapper.accounts(firstChildRank);
                require(initialValue >= firstChildRank, "not heap");
            }
            if (secondChildRank < size) {
                (, secondChildValue) = wrapper.accounts(secondChildRank);
                require(initialValue >= secondChildValue, "not heap");
            }
            if (thidChildRank < size) {
                (, thirdChildValue) = wrapper.accounts(thidChildRank);
                require(initialValue >= thirdChildValue, "not heap");
            }
        }
    }

    function test3HeapStructure() public {
        maxSortedUsers = 1000;
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

        uint256 size = wrapper.getSize();
        require(maxSortedUsers / 3 <= size, "size too low");
        require(size < maxSortedUsers, "size too high");
        verify3HeapStructure(size);
    }

}
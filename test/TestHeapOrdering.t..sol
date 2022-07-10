// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/HeapOrdering.sol";
import "test/commons/Test2Heap.sol";
import "test/commons/IHeapWrapper.sol";

contract HeapOrderingWrapper is IHeapWrapper {
    using HeapOrdering for HeapOrdering.HeapArray;
    HeapOrdering.HeapArray heap;

    function getValueOf(address _id) external view returns (uint256) {
        return heap.getValueOf(_id);
    }

    function getSize() external view returns (uint256) {
        return heap.size;
    }

    function accounts(uint256 _index) external view returns (address, uint256) {
        HeapOrdering.Account memory account = heap.accounts[_index];
        return (account.id, account.value);
    }

    function insert(
        address _id,
        uint256 _newValue,
        uint256 maxSortedUsers
    ) external {
        heap.update(_id, 0, _newValue, maxSortedUsers);
    }

    function remove(
        address _id,
        uint256 _formerValue,
        uint256 maxSortedUsers) external {
        heap.update(_id, _formerValue, 0, maxSortedUsers);
    }

    function increase(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 maxSortedUsers
    ) external {
        heap.update(_id, _formerValue, _newValue, maxSortedUsers);
    }

    function decrease(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 maxSortedUsers
    ) external {
        heap.update(_id, _formerValue, _newValue, maxSortedUsers);
    }

    function removeHead(uint256 maxSortedUsers) external returns (uint256 value) {
        address head = heap.getHead();
        if (head == address(0)) return 0;
        else {
            value = heap.getValueOf(head);
            heap.update(head, value, 0, maxSortedUsers);
        }
    }
}

contract TestHeapOrdering is Test2Heap {

    constructor () {
        wrapper = new HeapOrderingWrapper();
    }
}

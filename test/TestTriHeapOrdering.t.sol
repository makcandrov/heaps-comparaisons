// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/TriHeapOrdering.sol";
import "test/commons/Test3Heap.sol";
import "test/commons/IHeapWrapper.sol";

contract TriHeapOrderingWrapper is IHeapWrapper {
    using TriHeapOrdering for TriHeapOrdering.HeapArray;
    TriHeapOrdering.HeapArray heap;

    function getValueOf(address _id) external view returns (uint256) {
        return heap.getValueOf(_id);
    }

    function getSize() external view returns (uint256) {
        return heap.size;
    }

    function accounts(uint256 _index) external view returns (address, uint256) {
        TriHeapOrdering.Account memory account = heap.accounts[_index];
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

contract TestTriHeapOrdering is Test3Heap {

    constructor () {
        wrapper = new TriHeapOrderingWrapper();
    }
}

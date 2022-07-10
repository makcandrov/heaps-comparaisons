// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IHeapWrapper {
    function getValueOf(address _id) external view returns (uint256);
    function getSize() external view returns (uint256);
    function accounts(uint256) external view returns (address, uint256);

    function insert(
        address _id,
        uint256 _newValue,
        uint256 maxSortedUsers
    ) external;

    function remove(
        address _id,
        uint256 _formerValue,
        uint256 maxSortedUsers) external;

    function increase(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 maxSortedUsers
    ) external;

    function decrease(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 maxSortedUsers
    ) external;

    function removeHead(uint256 maxSortedUsers) external returns (uint256 value);
}
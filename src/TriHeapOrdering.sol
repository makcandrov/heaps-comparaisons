// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

library TriHeapOrdering {
    struct Account {
        address id; // The address of the account.
        uint256 value; // The value of the account.
    }

    struct HeapArray {
        Account[] accounts; // All the accounts.
        uint256 size; // The size of the heap portion of the structure, should be less than accounts length, the rest is an unordered array.
        mapping(address => uint256) ranks; // A mapping from an address to a rank in accounts.
    }

    /// ERRORS ///

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// INTERNAL ///

    /// @notice Updates an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with value `_formerValue` or when `_id` is not in the `_heap` with `_formerValue` equal to 0.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to update.
    /// @param _formerValue The former value of the account to update.
    /// @param _newValue The new value of the account to update.
    /// @param _maxSortedUsers The maximum size of the heap.
    function update(
        HeapArray storage _heap,
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 _maxSortedUsers
    ) internal {
        uint256 size = _heap.size;
        uint256 newSize = computeSize(size, _maxSortedUsers);
        if (size != newSize) _heap.size = newSize;

        if (_formerValue != _newValue) {
            if (_newValue == 0) remove(_heap, _id, _formerValue);
            else if (_formerValue == 0) insert(_heap, _id, _newValue, _maxSortedUsers);
            else if (_formerValue < _newValue) increase(_heap, _id, _newValue, _maxSortedUsers);
            else decrease(_heap, _id, _newValue);
        }
    }

    /// PRIVATE ///

    /// @notice Computes a new suitable size from `_size` that is smaller than `_maxSortedUsers`.
    /// @dev We use division by 2 to remove the leaves of the heap.
    /// @param _size The old size of the heap.
    /// @param _maxSortedUsers The maximum size of the heap.
    /// @return The new size computed.
    function computeSize(uint256 _size, uint256 _maxSortedUsers) private pure returns (uint256) {
        while (_size >= _maxSortedUsers) _size /= 3;
        return _size;
    }

    /// @notice Returns the account of rank `_rank`.
    /// @dev The first rank is 1 and the last one is length of the array.
    /// @dev Only call this function with positive numbers.
    /// @param _heap The heap to search in.
    /// @param _rank The rank of the account.
    /// @return The account of rank `_rank`.
    function getAccount(HeapArray storage _heap, uint256 _rank)
        private
        view
        returns (Account storage)
    {
        return _heap.accounts[_rank];
    }

    /// @notice Sets the value at `_rank` in the `_heap` to be `_newValue`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with a rank within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account in the heap to be set.
    /// @param _newValue The new value to set the `_rank` to.
    function setAccountValue(
        HeapArray storage _heap,
        uint256 _rank,
        uint256 _newValue
    ) private {
        _heap.accounts[_rank].value = _newValue;
    }

    /// @notice Sets `_rank` in the `_heap` to be `_account`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with a rank within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account in the heap to be set.
    /// @param _account The account to set the `_rank` to.
    function setAccount(
        HeapArray storage _heap,
        uint256 _rank,
        Account memory _account
    ) private {
        _heap.accounts[_rank] = _account;
        _heap.ranks[_account.id] = _rank;
    }

    /// @notice Moves an account up the heap until its value is smaller than the one of its parent.
    /// @dev This functions restores the invariant about the order of the values stored when the account at `_rank` is the only one with value greater than what it should be.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account to move.
    function shiftUp(
        HeapArray storage _heap,
        Account memory initialAccount,
        uint256 _rank
    ) private {
        Account memory fatherAccount;
        uint256 fatherRank;
        while (
            _rank != 0 &&
            initialAccount.value > (fatherAccount = getAccount(
                _heap,
                fatherRank = (_rank - 1) / 3
            )).value
        ) {
            setAccount(_heap, _rank, fatherAccount);
            _rank = fatherRank;
        }
        setAccount(_heap, _rank, initialAccount);
    }

    /// @notice Moves an account down the heap until its value is greater than the ones of its children.
    /// @dev This functions restores the invariant about the order of the values stored when the account at `_rank` is the only one with value smaller than what it should be.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account to move.
    function shiftDown(
        HeapArray storage _heap,
        Account memory initialAccount,
        uint256 _rank
    ) private {
        uint256 size = _heap.size;
        uint256 childRank = _rank * 3 + 1;

        Account memory firstChildAccount;
        Account memory secondChildAccount;
        Account memory thirdChildAccount;

        for (;;) {

            if (childRank + 2 < size) { // three children
                firstChildAccount = getAccount(_heap, childRank);
                secondChildAccount = getAccount(_heap, childRank + 1);
                thirdChildAccount = getAccount(_heap, childRank + 2);

                if (thirdChildAccount.value > secondChildAccount.value) {
                    if (thirdChildAccount.value > firstChildAccount.value) {
                        // 3
                        if (thirdChildAccount.value > initialAccount.value) {
                            setAccount(_heap, _rank, thirdChildAccount);
                            childRank += 2;
                        } else break;
                    } else {
                        // 1
                        if (firstChildAccount.value > initialAccount.value) {
                            setAccount(_heap, _rank, firstChildAccount);
                        } else break;
                    }
                } else {
                    if (secondChildAccount.value > firstChildAccount.value) {
                        // 2
                        if (secondChildAccount.value > initialAccount.value) {
                            setAccount(_heap, _rank, secondChildAccount);
                            childRank++;
                        } else break;
                    } else {
                        // 1
                        if (firstChildAccount.value > initialAccount.value) {
                            setAccount(_heap, _rank, firstChildAccount);
                        } else break;
                    }
                }
            } else if (childRank + 1 < size) { // two children
                firstChildAccount = getAccount(_heap, childRank);
                secondChildAccount = getAccount(_heap, childRank + 1);

                if (secondChildAccount.value > firstChildAccount.value) {
                    // 2
                    if (secondChildAccount.value > initialAccount.value) {
                        setAccount(_heap, _rank, secondChildAccount);
                        childRank++;
                    } else break;
                } else {
                    // 1
                    if (firstChildAccount.value > initialAccount.value) {
                        setAccount(_heap, _rank, firstChildAccount);
                    } else break;
                }
            } else if (childRank < size) { // one child
                firstChildAccount = getAccount(_heap, childRank);
                if (firstChildAccount.value > initialAccount.value) {
                    setAccount(_heap, _rank, firstChildAccount);
                    _rank = childRank;
                }
                break;
            } else break; // no child
            
            _rank = childRank;
            childRank = childRank * 3 + 1;
        }
        setAccount(_heap, _rank, initialAccount);
    }

    /// @notice Inserts an account in the `_heap`.
    /// @dev Only call this function when `_id` is not in the `_heap`.
    /// @dev Reverts with AddressIsZero if `_value` is 0.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to insert.
    /// @param _value The value of the account to insert.
    /// @param _maxSortedUsers The maximum size of the heap.
    function insert(
        HeapArray storage _heap,
        address _id,
        uint256 _value,
        uint256 _maxSortedUsers
    ) private {
        // `_heap` cannot contain the 0 address.
        if (_id == address(0)) revert AddressIsZero();

        uint256 size = _heap.size;
        uint256 accountsLength = _heap.accounts.length;

        if (size < accountsLength) {
            Account memory firstAccountNotSorted = _heap.accounts[size];

            _heap.ranks[firstAccountNotSorted.id] = accountsLength;
            _heap.accounts.push(firstAccountNotSorted);
        } else _heap.accounts.push();

        shiftUp(_heap, Account(_id, _value), size);
        _heap.size = computeSize(size + 1, _maxSortedUsers);
    }

    /// @notice Decreases the amount of an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with a value greater than `_newValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to decrease the amount.
    /// @param _newValue The new value of the account.
    function decrease(
        HeapArray storage _heap,
        address _id,
        uint256 _newValue
    ) private {
        uint256 rank = _heap.ranks[_id];

        if (rank < (_heap.size - 1) / 3)
            shiftDown(_heap, Account(_id, _newValue), rank);
        else setAccountValue(_heap, rank, _newValue);
    }

    /// @notice Increases the amount of an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with a smaller value than `_newValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to increase the amount.
    /// @param _newValue The new value of the account.
    /// @param _maxSortedUsers The maximum size of the heap.
    function increase(
        HeapArray storage _heap,
        address _id,
        uint256 _newValue,
        uint256 _maxSortedUsers
    ) private {
        uint256 rank = _heap.ranks[_id];
        setAccountValue(_heap, rank, _newValue);
        uint256 size = _heap.size;

        if (rank < size) shiftUp(_heap, Account(_id, _newValue), rank);
        else {
            Account memory firstAccountNotSorted = _heap.accounts[size];
            setAccount(_heap, rank, firstAccountNotSorted);
            shiftUp(_heap, Account(_id, _newValue), size);
            _heap.size = computeSize(size + 1, _maxSortedUsers);
        }
    }

    /// @notice Removes an account in the `_heap`.
    /// @dev Only call when this function `_id` is in the `_heap` with value `_removedValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to remove.
    /// @param _removedValue The value of the account to remove.
    function remove(
        HeapArray storage _heap,
        address _id,
        uint256 _removedValue
    ) private {
        uint256 rank = _heap.ranks[_id];
        delete _heap.ranks[_id];
        uint256 accountsLength = _heap.accounts.length;
        
        if (_heap.size == accountsLength) _heap.size--;
        if (rank == accountsLength - 1) {
            _heap.accounts.pop();
            return;
        }

        Account memory lastAccount = _heap.accounts[accountsLength - 1];
        _heap.accounts.pop();

        if (rank < _heap.size) {
            if (_removedValue > lastAccount.value) shiftDown(_heap, lastAccount, rank);
            else shiftUp(_heap, lastAccount, rank);
        } else setAccount(_heap, rank, lastAccount);
    }

    /// GETTERS ///

    /// @notice Returns the number of users in the `_heap`.
    /// @param _heap The heap parameter.
    /// @return The length of the heap.
    function length(HeapArray storage _heap) internal view returns (uint256) {
        return _heap.accounts.length;
    }

    /// @notice Returns the value of the account linked to `_id`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The value of the account.
    function getValueOf(HeapArray storage _heap, address _id) internal view returns (uint256) {
        Account memory account = getAccount(_heap, _heap.ranks[_id]);
        if (account.id != _id) return 0;
        else return account.value;
    }

    /// @notice Returns the address at the head of the `_heap`.
    /// @param _heap The heap to get the head.
    /// @return The address of the head.
    function getHead(HeapArray storage _heap) internal view returns (address) {
        if (_heap.accounts.length > 0) return getAccount(_heap, 0).id;
        else return address(0);
    }
}

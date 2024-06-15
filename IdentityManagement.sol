// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract IdentityManagement {
    address public owner;

    struct User {
        string username;
        string email;
        bool isRegistered;
    }

    mapping(address => User) public users;

    event UserRegistered(
        address indexed userAddress,
        string username,
        string email
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed to preform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(
        string memory username,
        string memory email
    ) external {
        require(!users[msg.sender].isRegistered, "User already registered");

        users[msg.sender] = User(username, email, true);
        emit UserRegistered(msg.sender, username, email);
    }

    function getUserDetails(
        address userAddress
    )
        external
        view
        returns (string memory username, string memory email, bool isRegistered)
    {
        User storage user = users[userAddress];
        return (user.username, user.email, user.isRegistered);
    }

    function isUserRegistered(
        address userAddress
    ) external view returns (bool) {
        return users[userAddress].isRegistered;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract UniversityRegistry {
    address public owner;

    struct University {
        string name;
        string location;
        bool isRegistered;
    }

    mapping(address => University) public universities;

    event UniversityRegistered(
        address indexed universityAddress,
        string name,
        string location
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed to preform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUniversity(
        string memory name,
        string memory location
    ) external onlyOwner {
        require(
            !universities[msg.sender].isRegistered,
            "University already registered"
        );

        universities[msg.sender] = University(name, location, true);
        emit UniversityRegistered(msg.sender, name, location);
    }

    function getUniversityDetails(
        address universityAddress
    )
        external
        view onlyOwner
        returns (string memory name, string memory location, bool isRegistered)
    {
        University storage university = universities[universityAddress];
        return (university.name, university.location, university.isRegistered);
    }

    function isUniversityRegistered(
        address universityAddress
    ) external onlyOwner view returns (bool) {
        return universities[universityAddress].isRegistered;
    }
}

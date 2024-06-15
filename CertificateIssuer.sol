// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract CertificateIssuer {
    address public owner;

    struct Certificate {
        address university;
        address student;
        string courseName;
        uint256 issueDate;
        bool isIssued;
    }

    uint256[] issuedCertificateIds;  
    mapping(uint256 => Certificate) public certificates;

    event CertificateIssued(
        uint256 certificateId,
        address indexed university,
        address indexed student,
        string courseName,
        uint256 issueDate
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed to perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function issueCertificate(address student, string memory courseName) external onlyOwner {
        require(student != address(0), "Invalid student address");

        uint256 certificateId = generateCertificateId();
        issuedCertificateIds.push(certificateId);  
        certificates[certificateId] = Certificate(
            msg.sender,
            student,
            courseName,
            block.timestamp,
            true
        );
        emit CertificateIssued(
            certificateId,
            msg.sender,
            student,
            courseName,
            block.timestamp
        );
    }

    function getIssuedCertificateIds() external view onlyOwner returns (uint256[] memory) {
        return issuedCertificateIds;
    }

    function getCertificateDetails(uint256 certificateId) external view returns (
        address university,
        address student,
        string memory courseName,
        uint256 issueDate,
        bool isIssued
    ) {
        Certificate storage certificate = certificates[certificateId];
        return (
            certificate.university,
            certificate.student,
            certificate.courseName,
            certificate.issueDate,
            certificate.isIssued
        );
    }

    function generateCertificateId() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.number))) % 100000000;
    }
}

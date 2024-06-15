// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;


import "./CertificateIssuer.sol";

contract CertificateVerifier {
    address public owner;
    CertificateIssuer public certificateIssuer;  

    struct VerificationRequest {
        address verifier;
        uint256 certificateId;
        bool isCompleted;
    }

    mapping(uint256 => VerificationRequest) public verificationRequests;

    event VerificationRequested(
        uint256 requestId,
        address indexed verifier,
        uint256 certificateId
    );

    event VerificationCompleted(uint256 requestId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed to preform this action");
        _;
    }

  
    constructor(address _certificateIssuerAddress) {
        owner = msg.sender;
        certificateIssuer = CertificateIssuer(_certificateIssuerAddress);
    }

    function requestVerification(uint256 certificateId) external {
        require(certificateId > 0, "Invalid certificate ID");
        require(
            !verificationRequests[certificateId].isCompleted,
            "Verification request already completed"
        );

        uint256 requestId = generateRequestId();
        verificationRequests[requestId] = VerificationRequest(
            msg.sender,
            certificateId,
            false
        );
        emit VerificationRequested(requestId, msg.sender, certificateId);
    }

    function completeVerification(uint256 requestId) external onlyOwner {
        require(
            verificationRequests[requestId].verifier != address(0),
            "Invalid verification request"
        );
        require(
            !verificationRequests[requestId].isCompleted,
            "Verification request already completed"
        );

        (address university, address student, string memory courseName, , ) = certificateIssuer.getCertificateDetails(
            verificationRequests[requestId].certificateId
        );


        verificationRequests[requestId].isCompleted = true;
        emit VerificationCompleted(requestId);
    }

    function getVerificationRequestDetails(
        uint256 requestId
    )
        external
        view
        returns (address verifier, uint256 certificateId, bool isCompleted)
    {
        VerificationRequest storage request = verificationRequests[requestId];
        return (request.verifier, request.certificateId, request.isCompleted);
    }

    function generateRequestId() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(msg.sender, block.timestamp, block.number)
                )
            );
    }
}

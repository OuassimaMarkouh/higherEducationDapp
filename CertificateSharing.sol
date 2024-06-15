// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./CertificateIssuer.sol";

contract CertificateSharing {
    address public owner;
    CertificateIssuer public certificateIssuer;  

    struct SharingRequest {
        address sender;
        address receiver;
        uint256 certificateId;
        bool isApproved;
        bool isCompleted;
    }

    mapping(uint256 => SharingRequest) public sharingRequests;
    mapping(address => uint256[]) public userToRequestIds;  
    event SharingRequested(
        uint256 requestId,
        address indexed sender,
        address indexed receiver,
        uint256 certificateId
    );

    event SharingApproved(uint256 requestId);

    event SharingCompleted(uint256 requestId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed to preform this action");
        _;
    }

    constructor(address _certificateIssuerAddress) {
        owner = msg.sender;
        certificateIssuer = CertificateIssuer(_certificateIssuerAddress);
    }

    function requestSharing(address receiver, uint256 certificateId) external {
        require(receiver != address(0), "Invalid receiver address");
        require(certificateId > 0, "Invalid certificate ID");

        uint256 requestId = generateRequestId();
        sharingRequests[requestId] = SharingRequest(
            msg.sender,
            receiver,
            certificateId,
            false,
            false
        );

        userToRequestIds[msg.sender].push(requestId);
        userToRequestIds[receiver].push(requestId);

        emit SharingRequested(requestId, msg.sender, receiver, certificateId);
    }

    function approveSharing(uint256 requestId) external onlyOwner {
        require(
            sharingRequests[requestId].receiver != address(0),
            "Invalid sharing request"
        );
        require(
            !sharingRequests[requestId].isApproved,
            "Sharing request already approved"
        );

        sharingRequests[requestId].isApproved = true;
        emit SharingApproved(requestId);
    }

    function completeSharing(uint256 requestId) external {
        require(
            sharingRequests[requestId].sender == msg.sender,
            "Not the sender of the request"
        );
        require(
            sharingRequests[requestId].isApproved,
            "Sharing request not approved"
        );
        require(
            !sharingRequests[requestId].isCompleted,
            "Sharing request already completed"
        );

        (address university, address student, string memory courseName, , ) = certificateIssuer.getCertificateDetails(
            sharingRequests[requestId].certificateId
        );


        sharingRequests[requestId].isCompleted = true;
        emit SharingCompleted(requestId);
    }

    function getSharingRequestDetails(
        uint256 requestId
    )
        external
        view
        returns (
            address sender,
            address receiver,
            uint256 certificateId,
            bool isApproved,
            bool isCompleted
        )
    {
        SharingRequest storage request = sharingRequests[requestId];
        return (
            request.sender,
            request.receiver,
            request.certificateId,
            request.isApproved,
            request.isCompleted
        );
    }

    function getUserRequestIds(address user) external view returns (uint256[] memory) {
        return userToRequestIds[user];
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

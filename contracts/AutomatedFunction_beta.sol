// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { Functions, FunctionsClient } from "./dev/functions/FunctionsClient.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import { AutomationCompatibleInterface } from "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract AutomatedFunctionsConsumer is FunctionsClient, ConfirmedOwner, AutomationCompatibleInterface {
    using Functions for Functions.Request;

    AggregatorV3Interface internal dataFeed;
    bytes public requestCBOR;
    bytes32 public latestRequestId;
    bytes public latestResponse;
    bytes public latestError;
    uint64 public subscriptionId;
    uint32 public fulfillGasLimit;
    uint256 public updateInterval;
    uint256 public lastUpkeepTimeStamp;
    uint256 public upkeepCounter;
    uint256 public responseCounter;

    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

    constructor(
        address oracle,
        uint64 _subscriptionId,
        uint32 _fulfillGasLimit,
        uint256 _updateInterval
    )
        FunctionsClient(oracle)
        ConfirmedOwner(msg.sender)
    {
        updateInterval = _updateInterval;
        subscriptionId = _subscriptionId;
        fulfillGasLimit = _fulfillGasLimit;
        lastUpkeepTimeStamp = block.timestamp;

        dataFeed = AggregatorV3Interface(
            <MOCK-DATA-FEED-ADDRESS>
        );
    }

    function getLatestData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function generateRequest(
        string calldata source,
        bytes calldata secrets,
        string[] calldata args
    ) public pure returns (bytes memory) {
        Functions.Request memory req;
        req.initializeRequest(
            Functions.Location.Inline,
            Functions.CodeLanguage.JavaScript,
            source
        );
        if (secrets.length > 0) {
            req.addRemoteSecrets(secrets);
        }
        if (args.length > 0) req.addArgs(args);

        return req.encodeCBOR();
    }

    function setRequest(
        uint64 _subscriptionId,
        uint32 _fulfillGasLimit,
        uint256 _updateInterval,
        bytes calldata newRequestCBOR
    ) external onlyOwner {
        updateInterval = _updateInterval;
        subscriptionId = _subscriptionId;
        fulfillGasLimit = _fulfillGasLimit;
        requestCBOR = newRequestCBOR;
    }

    function checkUpkeep(bytes memory) public view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (getLatestData() <= 9500000) || (getLatestData() >= 105000000);
    }

    function performUpkeep(bytes calldata) external override {
        // Check if the cooldown period has elapsed (30 minutes)
        require(block.timestamp >= lastUpkeepTimeStamp + 30 minutes, "Cooldown period not met");

        (bool upkeepNeeded, ) = checkUpkeep("");
        require(upkeepNeeded, "Upkeep not needed");

        lastUpkeepTimeStamp = block.timestamp;
        upkeepCounter = upkeepCounter + 1;

        bytes32 requestId = s_oracle.sendRequest(subscriptionId, requestCBOR, fulfillGasLimit);

        s_pendingRequests[requestId] = s_oracle.getRegistry();
        emit RequestSent(requestId);
        latestRequestId = requestId;
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        latestResponse = response;
        latestError = err;
        responseCounter = responseCounter + 1;
        emit OCRResponse(requestId, response, err);
    }

    function updateOracleAddress(address oracle) public onlyOwner {
        setOracle(oracle);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(
            bytes4(keccak256(bytes("approve(address,uint256)"))),
            to,
            amount
        ));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: Approval failed");
    }

    function safeTransfer(address token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(
            bytes4(keccak256(bytes("transfer(address,uint256)"))),
            to,
            amount
        ));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: Transfer failed");
    }

    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(
            bytes4(keccak256(bytes("transferFrom(address,address,uint256)"))),
            from,
            to,
            amount
        ));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TransferFrom failed");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "TransferHelper: ETH transfer failed");
    }
}

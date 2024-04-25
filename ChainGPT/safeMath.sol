
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath Library for uint256
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

// SafeMath Library for uint32
library SafeMath32 {
    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, "SafeMath32: addition overflow");

        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, "SafeMath32: subtraction overflow");
        uint32 c = a - b;

        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "SafeMath32: multiplication overflow");

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, "SafeMath32: division by zero");
        uint32 c = a / b;

        return c;
    }
}

// SafeMath Library for uint16
library SafeMath16 {
    function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        require(c >= a, "SafeMath16: addition overflow");

        return c;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b <= a, "SafeMath16: subtraction overflow");
        uint16 c = a - b;

        return c;
    }

    function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }

        uint16 c = a * b;
        require(c / a == b, "SafeMath16: multiplication overflow");

        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b > 0, "SafeMath16: division by zero");
        uint16 c = a / b;

        return c;
    }
}

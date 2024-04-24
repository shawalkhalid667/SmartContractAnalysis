// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/chat.sol";

contract BufferTest {
    using Buffer for Buffer.buffer;

    Buffer.buffer buf;

    function beforeAll() public {
        buf.init(10);
    }

    function checkInit() public {
        Assert.equal(buf.capacity, 10, "Capacity should be 10");
        Assert.equal(buf.buf.length, 10, "Buffer length should be 10");
    }

    function checkWrite() public {
        bytes memory data = "Hello";
        buf.write(data);
        Assert.equal(buf.buf.length, 10, "Buffer length should still be 10 after write");
        Assert.equal(abi.decode(buf.buf, (string)), "Hello", "Buffer should contain 'Hello'");
    }

    function checkAppend() public {
        bytes memory data = " World!";
        buf.append(data);
        Assert.equal(buf.buf.length, 16, "Buffer length should be 16 after append");
        Assert.equal(abi.decode(buf.buf, (string)), "Hello World!", "Buffer should contain 'Hello World!'");
    }

    function checkResize() public {
        bytes memory data = " Resize";
        buf.append(data);
        Assert.equal(buf.buf.length, 24, "Buffer length should be 24 after resize");
        Assert.equal(abi.decode(buf.buf, (string)), "Hello World! Resize", "Buffer should contain 'Hello World! Resize'");
    }
}

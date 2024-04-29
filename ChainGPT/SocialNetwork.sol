
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SimpleSocialNetwork contract
contract SimpleSocialNetwork {

    // Define the Post struct
    struct Post {
        string text;
        address owner;
    }

    // Define the Comment struct
    struct Comment {
        string text;
        address owner;
    }

    // Array to store all posts
    Post[] public posts;
    
    // Array to store all comments
    Comment[] public comments;

    // Mapping to track posts from each account
    mapping(address => uint[]) public postsFromAccount;

    // Mapping to track comments from each post
    mapping(uint => uint[]) public commentsFromPost;

    // Mapping to track the account that created a specific comment
    mapping(uint => address) public commentFromAccount;

    // Event triggered when a new post or comment is added
    event NewPostAdded(uint indexed postId, uint indexed commentId, address indexed owner);

    // Constructor to create the first post and comment with ID 0 (considered invalid)
    constructor() {
        posts.push(Post({text: "", owner: address(0)}));
        comments.push(Comment({text: "", owner: address(0)}));
    }

    // Function to check if there are any posts in the network
    function hasPosts() public view returns (bool) {
        return posts.length > 1;
    }

    // Function to create a new post with provided text
    function newPost(string memory _text) public {
        uint postId = posts.push(Post({text: _text, owner: msg.sender})) - 1;
        postsFromAccount[msg.sender].push(postId);
        emit NewPostAdded(postId, 0, msg.sender);
    }

    // Function to add a new comment to an existing post
    function newComment(uint _postId, string memory _text) public {
        require(_postId < posts.length, "Post does not exist");
        uint commentId = comments.push(Comment({text: _text, owner: msg.sender})) - 1;
        commentsFromPost[_postId].push(commentId);
        commentFromAccount[commentId] = msg.sender;
        emit NewPostAdded(_postId, commentId, msg.sender);
    }
}

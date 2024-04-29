pragma solidity ^0.8.0;

contract SimpleSocialNetwork {
    // Struct to store comment details
    struct Comment {
        uint256 id;
        string text;
        address owner;
    }
    
    // Struct to store post details
    struct Post {
        uint256 id;
        string text;
        address owner;
    }
    
    // Array to store all posts created in the network
    Post[] public posts;
    
    // Array to store all comments created in the network
    Comment[] public comments;
    
    // Mapping to track posts created by each account
    mapping(address => uint256[]) public postsFromAccount;
    
    // Mapping to track comments associated with each post
    mapping(uint256 => uint256[]) public commentsFromPost;
    
    // Mapping to store the account that created a specific comment
    mapping(uint256 => address) public commentFromAccount;
    
    // Event triggered when a new post or comment is added
    event NewPostAdded(uint256 postId, uint256 commentId, address owner);
    
    // Constructor initializes the contract with a first post and comment with ID 0
    constructor() {
        createPost("Welcome to SimpleSocialNetwork!");
        createComment(0, "Thank you for joining!");
    }
    
    // Function to check if there are any posts in the network
    function hasPosts() public view returns (bool) {
        return posts.length > 0;
    }
    
    // Function to create a new post with the provided text and associate it with the sender's account
    function createPost(string memory _text) public {
        uint256 postId = posts.length;
        posts.push(Post(postId, _text, msg.sender));
        postsFromAccount[msg.sender].push(postId);
        emit NewPostAdded(postId, 0, msg.sender);
    }
    
    // Function to add a new comment to an existing post
    function createComment(uint256 _postId, string memory _text) public {
        require(_postId < posts.length, "Post does not exist");
        uint256 commentId = comments.length;
        comments.push(Comment(commentId, _text, msg.sender));
        commentsFromPost[_postId].push(commentId);
        commentFromAccount[commentId] = msg.sender;
        emit NewPostAdded(_postId, commentId, msg.sender);
    }
    
    // Function to get post details by post ID
    function getPost(uint256 _postId) public view returns (uint256, string memory, address) {
        require(_postId < posts.length, "Post does not exist");
        Post memory post = posts[_postId];
        return (post.id, post.text, post.owner);
    }
    
    // Function to get comment details by comment ID
    function getComment(uint256 _commentId) public view returns (uint256, string memory, address) {
        require(_commentId < comments.length, "Comment does not exist");
        Comment memory comment = comments[_commentId];
        return (comment.id, comment.text, comment.owner);
    }
    
    // Function to get all comments associated with a post
    function getCommentsForPost(uint256 _postId) public view returns (uint256[] memory) {
        require(_postId < posts.length, "Post does not exist");
        return commentsFromPost[_postId];
    }
    
    // Function to get all posts created by an account
    function getPostsByAccount(address _account) public view returns (uint256[] memory) {
        return postsFromAccount[_account];
    }
}

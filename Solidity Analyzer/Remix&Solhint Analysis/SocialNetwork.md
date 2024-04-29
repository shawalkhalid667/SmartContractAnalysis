### socialNetwork.sol

#### Chat GPT contract

#### Remix
- **Gas Costs:**
  - Gas requirement of function `SimpleSocialNetwork.createPost` is infinite.
  - Gas requirement of function `SimpleSocialNetwork.createComment` is infinite.
  - Gas requirement of function `SimpleSocialNetwork.getPost` is infinite.
  - Gas requirement of function `SimpleSocialNetwork.getComment` is infinite.
  - Gas requirement of function `SimpleSocialNetwork.getCommentsForPost` is infinite.
  - Gas requirement of function `SimpleSocialNetwork.getPostsByAccount` is infinite.
- **Similar Variable Names:**
  - Variables have very similar names in functions `SimpleSocialNetwork.createPost` and `SimpleSocialNetwork.createComment`.
  - Variables have very similar names in functions `SimpleSocialNetwork.getPost` and `SimpleSocialNetwork.getComment`.
- **Guard Conditions:**
  - Use "assert(x)" if you never ever want x to be false. Use "require(x)" if x can be false due to e.g. invalid input or a failing external component.

#### Solhint
- Compiler version ^0.8.0 does not satisfy the ^0.5.8 semver requirement.
- Explicitly mark visibility in functions.

#### Chain GPT
- Does not compile.

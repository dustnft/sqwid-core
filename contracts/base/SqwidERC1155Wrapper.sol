//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../../@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../../@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../../@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "../../@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../../@openzeppelin/contracts/utils/Counters.sol";
import "../interface/ISqwidERC1155.sol";
import "../interface/INftRoyalties.sol";

abstract contract SqwidERC1155Wrapper is ERC721Holder, ERC1155Holder {
    using Counters for Counters.Counter;

    struct WrappedToken {
        uint256 tokenId; // SqwidERC1155 token id
        bool isErc721; // true - ERC721 / false - ERC1155
        uint256 extTokenId; // External token id
        address extNftContract; // External contract address
    }

    Counters.Counter internal _wrappedCounter;
    mapping(uint256 => WrappedToken) internal _wrappedTokens;

    event WrapToken(
        uint256 tokenId,
        bool isErc721,
        uint256 extTokenId,
        address extNftContract,
        uint256 amount,
        bool wrapped
    );

    modifier wrappedExists(uint256 tokenId) {
        require(_wrappedTokens[tokenId].tokenId > 0, "Wrapper: Wrapped token not found");
        _;
    }

    function getWrappedToken(uint256 tokenId)
        public
        view
        wrappedExists(tokenId)
        returns (WrappedToken memory)
    {
        return _wrappedTokens[tokenId];
    }

    function wrapERC721(address extNftContract, uint256 extTokenId)
        external
        virtual
        returns (uint256);

    function unwrapERC721(uint256 tokenId) external virtual;

    function _increaseSupply(uint256 wrappedId, uint256 amount) internal virtual;

    function wrapERC1155(
        address extNftContract,
        uint256 extTokenId,
        uint256 amount
    ) external virtual returns (uint256);

    function unwrapERC1155(uint256 tokenId) external virtual;

    function _getWrappedTokenId(address extNftContract, uint256 extTokenId)
        internal
        view
        returns (uint256)
    {
        uint256 tokenId;
        uint256 totalWrappedCount = _wrappedCounter.current();
        for (uint256 i; i < totalWrappedCount; i++) {
            if (
                _wrappedTokens[i + 1].extNftContract == extNftContract &&
                _wrappedTokens[i + 1].extTokenId == extTokenId
            ) {
                tokenId = _wrappedTokens[i + 1].tokenId;
                break;
            }
        }

        return tokenId;
    }
}
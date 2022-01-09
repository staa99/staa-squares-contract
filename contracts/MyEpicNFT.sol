// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "./libraries/Base64.sol";


contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  uint256 number;
  uint8 constant maxNFTs = 50;

  string constant comma = ',';
  string constant prefix = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"> <style>.base{ fill: rgb(';
  string constant stylePart = '); font-family: monospace; font-size: 14px; } .rect { fill: rgb(';
  string constant mainBody = '); }</style> <rect width="100%" height="100%" class="rect" /> <text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">';
  string constant suffix = "</text></svg>";

  string[] firstWords = ["Incredible", "Epic", "Massive", "Horrible", "Terrible", "Excellent"];
  string[] secondWords = ["Killer", "Pirate", "Robber", "Crazy", "Massive", "Mammoth"];
  string[] thirdWords = ["Jeep", "Crate", "Undies", "Junk", "Piece", "Failure"];

  event NewEpicNFTMinted(address indexed sender, uint256 tokenId);

  constructor() ERC721 ("Staa Squares", "SSQ") {
    console.log("This is my NFT contract. Woah!");
  }

  function generateRandomWords() internal returns (string memory) {
    return string(abi.encodePacked(pickRandomFirstWord(), pickRandomSecondWord(), pickRandomThirdWord()));
  }

  function generateRandomRGBs(uint256 tokenId) internal returns (string memory r, string memory g, string memory b, string memory r1, string memory g1, string memory b1) {
    uint8 r0 = generateRandomRGB(tokenId);
    uint8 g0 = generateRandomRGB(tokenId);
    uint8 b0 = generateRandomRGB(tokenId);

    r = Strings.toString(r0);
    g = Strings.toString(g0);
    b = Strings.toString(b0);
    r1 = Strings.toString(255 - r0);
    g1 = Strings.toString(255 - g0);
    b1 = Strings.toString(255 - b0);
  }

  function pickRandomFirstWord() internal returns (string memory) {
    // I seed the random generator. More on this in the lesson.
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD")));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord() internal returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD")));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord() internal returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD")));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function generateRandomRGB(uint256 tokenId) internal returns (uint8) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    return uint8(rand % 64);
  }

  function random(string memory input) internal returns (uint256) {
    number++;
    return uint256(keccak256(abi.encodePacked(input, block.difficulty, block.timestamp, Strings.toString(number))));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();
    require(newItemId < maxNFTs, "All NFTs have been minted");

    (string memory r, string memory g, string memory b, string memory r1, string memory g1, string memory b1) = generateRandomRGBs(newItemId);

    string memory backgroundColor = string(abi.encodePacked(
        r,
        comma,
        g,
        comma,
        b
      ));

    string memory textColor = string(abi.encodePacked(
        r1,
        comma,
        g1,
        comma,
        b1
      ));

    string memory words = generateRandomWords();

    string memory svg = string(abi.encodePacked(
        prefix,
        backgroundColor,
        stylePart,
        textColor,
        mainBody,
        words,
        suffix
      ));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            words,
            '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '"}'
          )
        )
      )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);

    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);

    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }

  function getNFTCount() public view returns(uint256) {
    return _tokenIds.current();
  }
}
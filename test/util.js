const { expect } = require("chai");

exports.getBalance = async (reefToken, address, name) => {
    const balance = await reefToken.balanceOf(address);
    const balanceFormatted = Number(ethers.utils.formatUnits(balance.toString(), "ether"));
    console.log(`\t\tBalance of ${name}:`, balanceFormatted);

    return balanceFormatted;
};

exports.formatBigNumber = (bigNumber) => {
    return Number(ethers.utils.formatUnits(bigNumber.toString(), "ether"));
};

exports.throwsException = async (promise, message) => {
    try {
        await promise;
        assert(false);
    } catch (error) {
        expect(error.message).contains(message);
    }
};

exports.logEvents = async (promise) => {
    const tx = await promise;
    const receipt = await tx.wait();

    let msg = "No events for this tx";
    if (receipt.events) {
        const eventsArgs = [];
        receipt.events.forEach((event) => {
            if (event.args) {
                eventsArgs.push(event.args);
            }
        });
        msg = eventsArgs;
    }
    console.log(msg);
};

exports.delay = (ms) => new Promise((res) => setTimeout(res, ms));

exports.getContracts = async (marketFee, owner) => {
    let nftContractAddress = config.contracts.nft;
    let marketContractAddress = config.contracts.market;
    let nft, market;

    if (!nftContractAddress || nftContractAddress == "") {
        // Deploy SqwidERC1155 contract
        console.log("\tdeploying NFT contract...");
        const NFT = await reef.getContractFactory("SqwidERC1155", owner);
        nft = await NFT.deploy();
        await nft.deployed();
        nftContractAddress = nft.address;
    } else {
        const NFT = await reef.getContractFactory("SqwidERC1155", owner);
        nft = await NFT.attach(nftContractAddress);
    }
    console.log(`\tNFT contact deployed ${nftContractAddress}`);

    if (!marketContractAddress || marketContractAddress == "") {
        // Deploy SqwidMarketplace contract
        console.log("\tdeploying Market contract...");
        const Market = await reef.getContractFactory("SqwidMarketplace", owner);
        market = await Market.deploy(marketFee, nftContractAddress);
        await market.deployed();
        marketContractAddress = market.address;
    } else {
        // Get deployed contract
        const Market = await reef.getContractFactory("SqwidMarketplace", owner);
        market = await Market.attach(marketContractAddress);
        await market.setNftContractAddress(nftContractAddress);
    }
    console.log(`\tMarket contract deployed in ${marketContractAddress}`);

    return { nft, market };
};

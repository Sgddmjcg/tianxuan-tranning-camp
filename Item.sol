pragma solidity ^0.4.24;

import "./ERC721.sol";

contract Item is ERC721 {
    
    struct GameItem {
        string name; // Item name
        uint level;  // Item level
        uint rarityLevel;  // 1 = normal, 2 = rare, 3 = epic, 4 = legendary
    }
    
    GameItem[] public items; // The array to store all items
    address public owner;  // Owner of the contract
    mapping(uint => uint) public itemPrices; // Mapping item ID to its price in wei

    constructor() public {
        owner = msg.sender; // The contract deployer is the owner
    }
    
    // Modifier to restrict access to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to transfer ownership to a new owner
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero address");
        owner = newOwner;
    }

    // Function to create a new item and assign it to an address
    function createItem(string _name, address _to) public onlyOwner {
        uint id = items.length; // Item ID = Length of the items array
        items.push(GameItem(_name, 5, 1)); // Example: Item ("Sword", 5, 1)
        _mint(_to, id); // Assign the new item (NFT) to the specified address
    }

    // Function to set item prices (only owner can set)
    function setItemPrice(uint itemId, uint price) public onlyOwner {
        require(itemId < items.length, "Item does not exist");
        itemPrices[itemId] = price;
    }

    // Function to batch mint items for multiple users
    function mintMultiple(address[] memory to, string[] memory names, uint[] memory levels, uint[] memory rarities) public onlyOwner {
        require(to.length == names.length && names.length == levels.length && levels.length == rarities.length, "Arrays must be of the same length");
        
        for (uint i = 0; i < to.length; i++) {
            uint id = items.length;
            items.push(GameItem(names[i], levels[i], rarities[i])); // Push new item with custom properties
            _mint(to[i], id);  // Mint the item for each address
        }
    }

    // Function to allow users to buy an item (payable function)
    function buyItem(uint itemId) public payable {
        uint price = itemPrices[itemId];
        require(price > 0, "This item is not available for purchase");
        require(msg.value >= price, "Insufficient funds to purchase the item");

        address buyer = msg.sender;
        _mint(buyer, itemId); // Mint the item to the buyer

        uint change = msg.value - price;
        if (change > 0) {
            msg.sender.transfer(change); // Return excess ETH to the buyer
        }
    }
}

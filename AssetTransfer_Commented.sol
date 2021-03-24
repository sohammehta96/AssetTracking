pragma solidity ^0.5.2;

//Defining the contract name
contract AssetTransfer{

	//Defining variables
    string public assetName;
    uint256 public orderCount = 0;
    uint256 public assetPrice;
    uint256 public transportFee;
    
	//Creating a constructor to accept values to identify the asset
    constructor(string memory _assetName, uint256 _assetPrice, uint256 _transportFee) public {
        assetName = _assetName;
        assetPrice = _assetPrice;
        transportFee = _transportFee;
    }
    
	//Creating mappings to track details for each order number
    mapping(uint256 => buyer) public buyers;
    mapping(uint256 => seller) public sellers;
    mapping(uint256 => transporter) public transporters;
    mapping(uint256 => stat) public status;
    
	//Creating structs to accept values based on the functions called
    struct buyer{
        address payable _buyer;
    }
    struct seller{
        address payable _seller;
    }
    struct transporter{
        address payable _transporter;
    }
    struct stat{
        string _status;
    }

	//Creating functions
    function createOrder() public {
	
		//Storing the address of the seller in the mapping sellers
        sellers[orderCount] = seller(msg.sender);
		
		//Changing the status of the associated order number
        status[orderCount] = stat("CREATED");
		
		//Incrementing the number of the orders
        orderCount ++;
    }
    function buyAsset(uint256 orderNumber) public payable {
	
		//Checking the status of the selected order number and if it is eligible to be bought
        require(keccak256(abi.encodePacked((status[orderNumber]._status))) ==
        keccak256(abi.encodePacked(("CREATED"))),"Not Applicable.");
		
		//Checking if the correct payment is received for the asset
        require(msg.value == assetPrice,"Please Pay.");
		
		//Sending the payment to the seller based on the address in the mapping
        sellers[orderNumber]._seller.transfer(assetPrice);
		
		//Storing the address of the seller in the mapping sellers
        buyers[orderNumber] = buyer(msg.sender);
		
		//Changing the status of the associated order number
        status[orderNumber] = stat("PURCHASED");
    }
    function transportAsset(uint256 orderNumber) public {
	
		//Checking the status of the selected order number and if it is eligible to be transported
        require(keccak256(abi.encodePacked((status[orderNumber]._status))) ==
        keccak256(abi.encodePacked(("PURCHASED"))),"Not Applicable.");
		
		//Storing the address of the seller in the mapping sellers
        transporters[orderNumber] = transporter(msg.sender);
		
		//Changing the status of the associated order number
        status[orderNumber] = stat("IN_TRANSIT");
    }
    function deliverAsset(uint256 orderNumber) public {
	
		//Checking the status of the selected order number and if it is eligible to be delivered
        require(keccak256(abi.encodePacked((status[orderNumber]._status))) ==
        keccak256(abi.encodePacked(("IN_TRANSIT"))),"Not Applicable.");
        
        //Checking if the person calling the function is the transporter associated with the order number
        require(msg.sender == transporters[orderNumber]._transporter,
        "You are not the transporter!");
		
		//Changing the status of the associated order number
        status[orderNumber] = stat("DELIVERED");
    }
    function acceptDelivery(uint256 orderNumber) public payable{
	
		//Checking the status of the selected order number and if it is eligible to be finalized
        require(keccak256(abi.encodePacked((status[orderNumber]._status))) ==
        keccak256(abi.encodePacked(("DELIVERED"))),"Not Applicable.");
        
        //Checking if the person calling the function is the buyer associated with the order number
        require(msg.sender == buyers[orderNumber]._buyer,
        "You are not the buyer!");
        
        //Checking if the correct payment is received for the transport of the asset
        require(msg.value == transportFee,"Please Pay.");
		
		//Changing the status of the associated order number
        status[orderNumber] = stat("FINALIZED");
        
        //Sending the payment to the transporter based on the address in the mapping
        transporters[orderNumber]._transporter.transfer(transportFee);
    }
}
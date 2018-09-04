pragma solidity ^0.4.22;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import 'openzeppelin-solidity/contracts/AddressUtils.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol";
import '../consortium/DepositHandler.sol';

contract DiamondRegistry is ERC721Basic, Ownable {
  using SafeMath for uint256;
  using AddressUtils for address;

  uint256 public EtherUsdRate;
  uint256 internal basePricePerCarat = 20;
  uint256 internal pricePowerx100 = 150;
  DepositHandler public depositHandler;
  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;
  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;
  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;
  //mapping (uint256 => Diamond) public diamondsInfo;
  Diamond[] public diamonds;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }
  /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }
  struct Diamond{
      uint diamondId;
      string certificateNumber;
      string agency;
      uint caratWeight;
  }
  event DiamondRegistered(address depositHandler, uint tokenID, string certifier, string certificateNumber, uint caratWeight,address registrant, uint timestamp);
  event DiamondRemoved(uint tokenID, address remover , address removedFrom ,uint timestamp);

  function() public payable {
    depositHandler.deposit.value(msg.value)(msg.sender);
  }

  constructor(DepositHandler _depositHandler, uint _initialRate) Ownable() public {
      EtherUsdRate = _initialRate;
      depositHandler = _depositHandler;
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  function balanceOf(address _owner) public view returns (uint256) {
      require(_owner != address(0));
      return ownedTokensCount[_owner];
  }
  function register(string _certifier,string _certificateNumber, uint _caratWeight) public payable {
      uint cost= getPriceETH(_caratWeight);
      // require(msg.value >= cost`);`
      uint tokenId = diamonds.length; //uint(keccak256(_certifier,_certificateNumber,_caratWeight));
      require(tokenOwner[tokenId] == address(0));
      Diamond memory newDiamond;
      newDiamond.diamondId = tokenId;
      newDiamond.agency =_certifier;
      newDiamond.certificateNumber = _certificateNumber;
      newDiamond.caratWeight =_caratWeight;
      diamonds.push(newDiamond);
      tokenOwner[tokenId] = msg.sender;
      ownedTokensCount[msg.sender] += 1;
      depositHandler.deposit.value(msg.value)(msg.sender);
      emit DiamondRegistered(address(depositHandler), tokenId, _certifier, _certificateNumber, _caratWeight,msg.sender, now);
  }
  /* function registerDiamonds(bytes[] _certifiers, string[] _certificateNumbers, uint[] _caratWeights) payable external {
      require(_certifiers.length == _caratWeights.length);
      require(_certifiers.length == _certificateNumbers.length);
      uint totalFee;
      for (uint i = 0; i < _certifiers.length; i++){
          register(_certifiers[i],_certificateNumbers[i],_caratWeights[i]);
          totalFee+= getCost(_caratWeights[i]);
      }
      require(msg.value >= totalFee,"not enough fees");
  } */
  /**
   * @dev Approves another address to transfer the given token ID
   * @dev The zero address indicates there is no approved address.
   * @dev There can only be one approved address per token at a given time.
   * @dev Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  function getDepositHandler () public view returns (address) {
    return address(depositHandler);
  }
  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for a the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }
  /**
   * @dev Sets or unsets the approval of a given operator
   * @dev An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }
  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }
  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }
/**
   * @dev Internal function to clear current approval of a given token ID
   * @dev Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }
  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }
  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }
    /**
   * @dev Transfers the ownership of a given token ID to another address
   * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));
    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);
    emit Transfer(_from, _to, _tokenId);
  }
  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    canTransfer(_tokenId)
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }
  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }

  function removeFaultyToken(uint _tokenId) onlyOwner public {
        address removedFrom =  tokenOwner[_tokenId];
        ownedTokensCount[removedFrom] -= 1;
        delete diamonds[_tokenId];
        delete tokenOwner[_tokenId];
        emit DiamondRemoved( _tokenId, removedFrom ,msg.sender , now);
  }

  function getPriceUSD(uint _centiCaratWeight) public view returns(uint){
      return basePricePerCarat * (_centiCaratWeight / 100); // + (_centiCaratWeight / 100) ^ (pricePowerx100 / 100);
  }

  function getPricePennies(uint _centiCaratWeight) public view returns(uint){
      return getPriceUSD(_centiCaratWeight) * 100;
  }

  function getPriceWEI(uint _centiCaratWeight) public view returns(uint) {
      uint pennyPrice = getPricePennies(_centiCaratWeight);
      uint weiPrice = pennyPrice* (10**16) /EtherUsdRate ;
      return (weiPrice);
  }

  function getPriceETH(uint _centiCaratWeight) public view returns(uint) {
      uint usdPrice = getPriceUSD(_centiCaratWeight);
      uint etherPrice = usdPrice/EtherUsdRate;
      return (etherPrice);
  }

  function setBasePricePerCarat (uint256 _basePricePerCarat) onlyOwner public {
    basePricePerCarat = _basePricePerCarat;
  }

  function getBasePricePerCarat () public view returns (uint256){
    return basePricePerCarat;
  }

  function setPricePowerx100 (uint256 _pricePowerx100) onlyOwner public {
    pricePowerx100 = _pricePowerx100;
  }

  function getPricePowerx100 () public view returns (uint256) {
    return pricePowerx100;
  }

  function setETHUSD(uint _rate) public{
      EtherUsdRate = _rate;
  }

  function getPrices(uint _centiCaratWeight) public view returns (uint, uint) {
    return (getPricePennies(_centiCaratWeight), getPriceWEI(_centiCaratWeight));
  }

  function liquidate () onlyOwner public {
    owner.transfer(address(this).balance);
  }
}

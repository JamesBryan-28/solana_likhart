class NFT {
  String? collectionTokenId;
  String? name;
  String? description;
  String? imageUrl;
  String? chain;
  String? network;

  NFT(
      {this.collectionTokenId,
        this.name,
        this.description,
        this.imageUrl,
        this.chain,
        this.network});

  NFT.fromJson(Map<String, dynamic> json) {
    collectionTokenId = json['collectionTokenId'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    chain = json['chain'];
    network = json['network'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectionTokenId'] = this.collectionTokenId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['imageUrl'] = this.imageUrl;
    data['chain'] = this.chain;
    data['network'] = this.network;
    return data;
  }
}
class ProductService{
  int id;
  String name;

  ProductService({this.id,this.name});

  factory ProductService.fromJson(Map<String,dynamic> json){
    return ProductService(id: json['id'],name:json['name']);
  }
}
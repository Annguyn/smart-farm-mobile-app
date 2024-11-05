class DeviceModel {
  String name = "";
  String color = "";
  bool isActive = false;
  String icon = "";
  String mode = "";

  DeviceModel({
    required this.name,
    required this.color,
    required this.isActive,
    required this.icon,
  }) : mode = (name == 'Smart water pump' && isActive) ? 'automatic' : 'manual';

  DeviceModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    color = json['color'];
    isActive = json['isActive'];
    icon = json['icon'];
    mode = json['mode']; // Add mode property
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['color'] = this.color;
    data['isActive'] = this.isActive;
    data['icon'] = this.icon;
    data['mode'] = this.mode;
    return data;
  }
}
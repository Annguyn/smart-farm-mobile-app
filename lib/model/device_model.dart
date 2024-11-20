class DeviceModel {
  String name = "";
  String color = "";
  bool isActive = false;
  String icon = "";
  String? mode; // Make mode nullable

  DeviceModel({
    required this.name,
    required this.color,
    required this.isActive,
    required this.icon,
  }) {
    if (name == 'Smart water pump' || name == 'Smart Curtain' || name == 'Smart Fan') {
      mode = isActive ? 'automatic' : 'manual';
    }
  }

  DeviceModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    color = json['color'];
    isActive = json['isActive'];
    icon = json['icon'];
    mode = json['mode'];
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
import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const ServiceCategory({required this.id, required this.name, required this.icon, required this.color});
}

final List<ServiceCategory> categories = [
  const ServiceCategory(id: 'plumber', name: 'Plumber', icon: '🛠', color: Color(0xFFE57373)),
  const ServiceCategory(id: 'electrician', name: 'Electrician', icon: '⚡', color: Color(0xFFFFD54F)),
  const ServiceCategory(id: 'carpenter', name: 'Carpenter', icon: '🔨', color: Color(0xFF8D6E63)),
  const ServiceCategory(id: 'ac', name: 'AC & Cooling', icon: '❄️', color: Color(0xFF4FC3F7)),
  const ServiceCategory(id: 'painter', name: 'Painter', icon: '🎨', color: Color(0xFFAED581)),
  const ServiceCategory(id: 'roofer', name: 'Roofer', icon: '🏠', color: Color(0xFF90A4AE)),
  const ServiceCategory(id: 'locksmith', name: 'Locksmith', icon: '🔐', color: Color(0xFFFFB74D)),
  const ServiceCategory(id: 'handyman', name: 'Handyman', icon: '🧰', color: Color(0xFF7986CB)),
  const ServiceCategory(id: 'cleaning', name: 'Cleaning', icon: '🧹', color: Color(0xFF4DD0E1)),
  const ServiceCategory(id: 'carpet', name: 'Carpet Clean', icon: '🛋️', color: Color(0xFFBA68C8)),
  const ServiceCategory(id: 'window', name: 'Window Clean', icon: '🪟', color: Color(0xFF64B5F6)),
  const ServiceCategory(id: 'laundry', name: 'Laundry', icon: '👕', color: Color(0xFF81C784)),
  const ServiceCategory(id: 'garden', name: 'Gardening', icon: '🌿', color: Color(0xFF66BB6A)),
  const ServiceCategory(id: 'computer', name: 'PC Repair', icon: '🖥', color: Color(0xFF5C6BC0)),
  const ServiceCategory(id: 'phone', name: 'Phone Repair', icon: '📱', color: Color(0xFF42A5F5)),
  const ServiceCategory(id: 'tv', name: 'TV Setup', icon: '📺', color: Color(0xFF78909C)),
  const ServiceCategory(id: 'wifi', name: 'WiFi & Net', icon: '🌐', color: Color(0xFF26A69A)),
  const ServiceCategory(id: 'barber', name: 'Barber', icon: '💇', color: Color(0xFFF06292)),
  const ServiceCategory(id: 'makeup', name: 'Makeup', icon: '💄', color: Color(0xFFEC407A)),
  const ServiceCategory(id: 'tailor', name: 'Tailor', icon: '🧵', color: Color(0xFFAB47BC)),
  const ServiceCategory(id: 'fitness', name: 'Fitness', icon: '🏋️', color: Color(0xFFEF5350)),
  const ServiceCategory(id: 'mechanic', name: 'Car Mechanic', icon: '🚗', color: Color(0xFF78909C)),
  const ServiceCategory(id: 'moto', name: 'Moto Repair', icon: '🛵', color: Color(0xFFFF7043)),
  const ServiceCategory(id: 'tire', name: 'Tire Service', icon: '🔧', color: Color(0xFF8D6E63)),
  const ServiceCategory(id: 'grocery', name: 'Grocery', icon: '🛒', color: Color(0xFF66BB6A)),
  const ServiceCategory(id: 'food', name: 'Food Delivery', icon: '🍲', color: Color(0xFFFFCA28)),
  const ServiceCategory(id: 'courier', name: 'Courier', icon: '📦', color: Color(0xFFFFA726)),
  const ServiceCategory(id: 'shopping', name: 'Shopping', icon: '🛍️', color: Color(0xFFEC407A)),
  const ServiceCategory(id: 'solar', name: 'Solar Panel', icon: '☀️', color: Color(0xFFFFEE58)),
  const ServiceCategory(id: 'hvac', name: 'HVAC', icon: '🔥', color: Color(0xFFFF7043)),
  const ServiceCategory(id: 'cctv', name: 'CCTV Install', icon: '📹', color: Color(0xFF5C6BC0)),
  const ServiceCategory(id: 'water', name: 'Water Tank', icon: '💧', color: Color(0xFF29B6F6)),
  const ServiceCategory(id: 'vet', name: 'Vet Visits', icon: '🐶', color: Color(0xFFA1887F)),
  const ServiceCategory(id: 'grooming', name: 'Pet Grooming', icon: '✂️', color: Color(0xFFFFB74D)),
];

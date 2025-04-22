import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<Map<String, dynamic>> items,
    required int tableNumber,
  }) async {
    try {
      final total = _calculateTotal(items);
      // Always create in activeOrders first
      final orderRef = await _firestore.collection('activeOrders').add({
        'userId': userId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'items': items,
        'tableNumber': tableNumber,
        'status': 'pending',
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> completeOrder(String orderId) async {
    final doc = await _firestore.collection('activeOrders').doc(orderId).get();
    if (doc.exists) {
      await _firestore.collection('pastOrders').doc(orderId).set(doc.data()!);
      await _firestore.collection('activeOrders').doc(orderId).delete();
    }
  }

  // Add item to existing order's array
  Future<void> addItemToOrder({
    required String orderId,
    required Map<String, dynamic> item,
  }) async {
    await _firestore.collection('Orders').doc(orderId).update({
      'items': FieldValue.arrayUnion([item]),
      'total': FieldValue.increment(item['price'] * item['quantity']),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }
}
